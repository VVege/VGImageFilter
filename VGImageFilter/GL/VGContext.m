//
//  VGContext.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGContext.h"
#import <GLKit/GLKit.h>

@interface VGContext()
@end

@implementation VGContext
static VGContext *__context;
+ (VGContext *)sharedContext {
    static dispatch_once_t oneToken;
    
    dispatch_once(&oneToken, ^{
        
        __context = [[VGContext alloc]init];
        
    });
    return __context;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupContext];
    }
    return self;
}

#pragma mark - Private
- (void)setupContext{
    _glContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_glContext || ![EAGLContext setCurrentContext:_glContext]) {
        NSLog(@"context load fail");
    }
    [EAGLContext setCurrentContext:_glContext];
}
@end
