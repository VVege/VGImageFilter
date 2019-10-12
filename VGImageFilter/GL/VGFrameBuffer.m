//
//  VGFrameBuffer.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/12.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGFrameBuffer.h"
#import <GLKit/GLKit.h>
#import "VGContext.h"

@interface VGFrameBuffer()
@property(nonatomic, assign)GLuint frameBuffer;
@property(nonatomic, assign)GLuint texture;
@end

@implementation VGFrameBuffer
- (instancetype)initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        _renderSize = size;
        [self genTexture];
    }
    return self;
}

- (void)genTexture{
    [self deleteResource];    
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _renderSize.width, _renderSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
}

- (void)deleteResource{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    
    glDeleteTextures(1, &_texture);
    _texture = 0;
}

#pragma mark - Public
- (void)use{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
}

- (GLuint)useTexture{
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _texture);
    return 2;
}

- (void)clean{
    [self deleteResource];
}
@end
