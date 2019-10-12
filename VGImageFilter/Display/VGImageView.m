//
//  VGImageView.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGImageView.h"
#import "VGContext.h"
#import "VGFrameBuffer.h"
#import "VGProgram.h"

@interface VGImageView()
@property(nonatomic, strong)VGProgram *program;
@property(nonatomic, strong)CAEAGLLayer *glLayer;
@property(nonatomic, assign)GLuint renderBuffer;
@property(nonatomic, assign)GLuint renderFrameBuffer;
@property(nonatomic, assign)GLint backingWidth;
@property(nonatomic, assign)GLint backingHeight;
@property(nonatomic, assign)GLuint vbo;
@end

@implementation VGImageView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _glLayer = [[CAEAGLLayer alloc]init];
        _glLayer.contentsScale = [[UIScreen mainScreen]scale];
        _glLayer.opaque = YES;
        _glLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        _glLayer.frame = self.bounds;
        [self.layer addSublayer:_glLayer];
        
        [VGContext sharedContext];
        [self setupProgram];
        [self setupVertexBufferData];
        [self setupRenderBuffer];
    }
    return self;
}

- (void)dealloc
{
    [self clean];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.glLayer.frame = self.bounds;
}

- (void)setupProgram{
    self.program = [[VGProgram alloc]init];
    NSString *vShaderPath = [[NSBundle mainBundle]pathForResource:@"normal" ofType:@"vsh"];
    NSString *fShaderPath = [[NSBundle mainBundle]pathForResource:@"normal" ofType:@"fsh"];
    [self.program loadShaders:vShaderPath frag:fShaderPath];
}

- (void)setupVertexBufferData{
    
    //通用顶点数组
    GLfloat quadVertexData[] = {
        -1.0,1.0, 0.0, 1.0,
        1.0,1.0, 1.0, 1.0,
        -1.0, 1.0, 0.0, 0.0,
        1.0, -1.0,1.0, 0.0,
    };
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertexData), quadVertexData, GL_STATIC_DRAW);
}

- (void)setupRenderBuffer{
    
    glGenFramebuffers(1, &_renderFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _renderFrameBuffer);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [[VGContext sharedContext].glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)clean{
    glDeleteProgram(_program.programId);
    
    glDeleteBuffers(1, &_vbo);
    _vbo = 0;
    
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
}

#pragma mark - VGInputProtocol
- (void)updateInputWithFrameBuffer:(nonnull VGFrameBuffer *)frameBuffer {
    
    glUseProgram(self.program.programId);
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.renderFrameBuffer);
    
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLint position =  glGetAttribLocation(self.program.programId, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*4, NULL);
    
    GLint texCoord = glGetAttribLocation(self.program.programId, "texCoord");
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*4, NULL+2*sizeof(GL_FLOAT));
    
    GLuint textureLevel = [frameBuffer useTexture];
    GLint sampler = glGetUniformLocation(self.program.programId, "Sampler");
    glUniform1i(sampler, textureLevel);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [[VGContext sharedContext].glContext presentRenderbuffer:self.renderBuffer];
}
@end
