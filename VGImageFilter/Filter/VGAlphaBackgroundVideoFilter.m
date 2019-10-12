//
//  VGVideoFilter.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/6/21.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGAlphaBackgroundVideoFilter.h"
#import "VGProgram.h"
#import <AVFoundation/AVUtilities.h>
#import <CoreVideo/CoreVideo.h>
#import <GLKit/GLKit.h>
#import "VGContext.h"
#import "VGFrameBuffer.h"

@interface VGAlphaBackgroundVideoFilter()
{
    VGProgram *program;
}
@property(nonatomic, assign)VGAlphaBackgroundColor color;
@end

@implementation VGAlphaBackgroundVideoFilter

- (instancetype)initWithColor:(VGAlphaBackgroundColor)color
{
    self = [super init];
    if (self) {
        _color = color;
        [self setupProgram];
    }
    return self;
}

- (void)renderTextureFromFrameBuffer:(VGFrameBuffer *)inputFrameBuffer{
    [self.outputFrameBuffer use];
    glUseProgram(program.programId);
    glViewport(0, 0, self.outputFrameBuffer.renderSize.width, self.outputFrameBuffer.renderSize.height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLuint samplerIndex = [inputFrameBuffer useTexture];
    glUniform1i(glGetUniformLocation(program.programId, "Sampler"), samplerIndex);
    
    int typeValue = 0;
    GLint type = glGetUniformLocation(program.programId, "type");
    switch (_color) {
        case VGAlphaBackgroundColorBlack:
            typeValue = 0;
            break;
        case VGAlphaBackgroundColorGreen:
            typeValue = 1;
            break;
    }
    glUniform1i(type, typeValue);
    
    GLint position =  glGetAttribLocation(program.programId, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*4, NULL);
    
    GLint texCoord = glGetAttribLocation(program.programId, "texCoord");
    glEnableVertexAttribArray(texCoord);
    glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*4, NULL+2*sizeof(GL_FLOAT));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - Input
- (void)updateInputWithFrameBuffer:(VGFrameBuffer *)frameBuffer {
    if (self.outputFrameBuffer == nil){
        self.outputFrameBuffer = [[VGFrameBuffer alloc]initWithSize:frameBuffer.renderSize];
    }
    [self renderTextureFromFrameBuffer:frameBuffer];
    [self process];
}

#pragma mark - Private
- (void)setupProgram{
    NSString *vPath = [[NSBundle mainBundle]pathForResource:@"normal" ofType:@"vsh"];
    NSString *fPath = [[NSBundle mainBundle]pathForResource:@"AlphaBackground" ofType:@"fsh"];
    program = [[VGProgram alloc]init];
    [program loadShaders:vPath frag:fPath];
}
@end
