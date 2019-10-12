//
//  VGMovieYUVRender.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGMovieYUVRender.h"
#import "VGFrameBuffer.h"
#import "VGProgram.h"
#import <GLKit/GLKit.h>
#import <AVFoundation/AVUtilities.h>
#import "VGContext.h"

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
static const GLfloat kColorConversion601[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

@interface VGMovieYUVRender()
{
    VGProgram   *_program;
    GLuint vbo;
    
    const GLfloat *_preferredConversion;
    
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
}
@property GLfloat preferredRotation;
@property CGSize presentationSize;

@end

@implementation VGMovieYUVRender

- (instancetype)init
{
    self = [super init];
    if (self) {
        [VGContext sharedContext];
        [self setupProgram];
        [self setupTextureCache];
        //default BT.709
        _preferredConversion = kColorConversion709;
    }
    return self;
}

- (void)dealloc
{
    [self cleanUpTextures];
    [self cleanUpBuffers];
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
}

#pragma mark - Setup
- (void)setupProgram{
    NSString *vPath = [[NSBundle mainBundle]pathForResource:@"RotationVertex" ofType:@"vsh"];
    NSString *fPath = [[NSBundle mainBundle]pathForResource:@"YUVConverse" ofType:@"fsh"];
    _program = [[VGProgram alloc]init];
    [_program loadShaders:vPath frag:fPath];
}

- (void)setupTextureCache{
    if (!_videoTextureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [VGContext sharedContext].glContext, NULL, &_videoTextureCache);
        if (err != noErr) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        }
    }
}

- (void)setupVertexBufferData{
    
    int backingWidth = self.presentationSize.width;
    int backingHeight = self.presentationSize.height;
    
    if (backingWidth == 0 || backingHeight == 0){
        NSLog(@"error:缓冲错误 width:%d height:%d",backingWidth, backingHeight);
        return;
    }
    
    CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(self.presentationSize, CGRectMake(0, 0, backingWidth, backingHeight));
    
    CGSize size = CGSizeZero;
    CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width/backingWidth, vertexSamplingRect.size.height/backingHeight);
    if (cropScaleAmount.width > cropScaleAmount.height) {
        size.width = 1.0;
        size.height = cropScaleAmount.height / cropScaleAmount.width;
    }else{
        size.width = 1.0;
        size.height = cropScaleAmount.width / cropScaleAmount.height;
    }
    
    //理解纹理翻转设置的原因
    GLfloat quadVertexData[] = {
        -1 * size.width,-1 * size.height, 0.0, 1.0,
        size.width, -1 * size.height, 1.0, 1.0,
        -1 * size.width, size.height, 0.0, 0.0,
        size.width, size.height,1.0, 0.0,
    };
    
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertexData), quadVertexData, GL_STATIC_DRAW);
}

#pragma mark - clear
- (void)cleanUpBuffers {
    glDeleteBuffers(1, &vbo);
    vbo = 0;
}

- (void)cleanUpTextures
{
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
}

#pragma mark - render
- (void)drawWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    glUseProgram(_program.programId);
    glViewport(0, 0, self.presentationSize.width, self.presentationSize.height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    CVReturn err;
    if (pixelBuffer != NULL) {
        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        if (!_videoTextureCache) {
            NSLog(@"无视频纹理缓存");
            return;
        }
        [self cleanUpTextures];
        
        CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
        
        NSString *ITU_R_601_4 = (NSString *)kCVImageBufferYCbCrMatrix_ITU_R_601_4;
        NSString *colorFormat = (__bridge NSString *)colorAttachments;
        
        if ([colorFormat isEqualToString:ITU_R_601_4]) {
            _preferredConversion = kColorConversion601;
        }else{
            _preferredConversion = kColorConversion709;
        }
        
        //Y plane
        glActiveTexture(GL_TEXTURE0);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, frameWidth, frameHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &_lumaTexture);
        if (err) {
            NSLog(@"错误: pixelBuffer 获取Y纹理失败 %d",err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        GLint samplerY = glGetUniformLocation(_program.programId, "SamplerY");
        glUniform1i(samplerY, 0);
        
        //UV plane
        glActiveTexture(GL_TEXTURE1);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, frameWidth / 2, frameHeight / 2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &_chromaTexture);
        
        if (err) {
            NSLog(@"错误: pixelBuffer 获取UV纹理失败 %d",err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        GLint samplerUV = glGetUniformLocation(_program.programId, "SamplerUV");
        glUniform1i(samplerUV, 1);
         
    }
    
    //uniform
    GLint preferredRotation = glGetUniformLocation(_program.programId, "preferredRotation");
    glUniform1f(preferredRotation, self.preferredRotation);
    
    GLint preferredConversion = glGetUniformLocation(_program.programId, "colorConversionMatrix");
    glUniformMatrix3fv(preferredConversion, 1, GL_FALSE, _preferredConversion);
    
    //vertices
    GLint position =  glGetAttribLocation(_program.programId, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*4, NULL);
    
    GLint texCoord = glGetAttribLocation(_program.programId, "texCoord");
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*4, NULL+2*sizeof(GL_FLOAT));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (CGImageRef)makeImage:(CVPixelBufferRef)pixelBuffer{
    
    glFinish();
    
    int width = self.presentationSize.width, height = self.presentationSize.height;
    int size = width * height * 4;
    GLubyte *buffer = malloc(size);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, size, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // 此时的 imageRef 是上下颠倒的，调用 CG 的方法重新绘制一遍，刚好翻转过来
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    free(buffer);
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return image.CGImage;
}

#pragma mark - Public
- (void)prepareWithRotation:(CGFloat)rotation videoSize:(CGSize)videoSize{
    self.preferredRotation = rotation;
    self.presentationSize = videoSize;
    [self cleanUpBuffers];
    [self setupVertexBufferData];
}

- (void)render:(CVPixelBufferRef)pixelBuffer{
    [self drawWithPixelBuffer:pixelBuffer];
}

- (CGImageRef)image:(CVPixelBufferRef)pixelBuffer{
    
    [self drawWithPixelBuffer:pixelBuffer];
    return [self makeImage:pixelBuffer];
}
@end
