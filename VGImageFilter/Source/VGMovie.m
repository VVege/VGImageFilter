//
//  VGMovie.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGMovie.h"
#import <OpenGLES/ES2/gl.h>
#import "VGFrameBuffer.h"
#import "VGInputProtocol.h"
#import "VGMovieDataReader.h"
#import "VGMovieYUVRender.h"

@interface VGMovie()<VGMovieDataReaderDelegate>
@property(nonatomic, strong)VGMovieDataReader *movieReader;
@property(nonatomic, strong)VGMovieYUVRender *render;
@end

@implementation VGMovie
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _movieReader = [[VGMovieDataReader alloc]initWithPath:path];
        _movieReader.delegate = self;
        
        _render = [[VGMovieYUVRender alloc]init];
    }
    return self;
}

- (CMTime)duration {
    return self.movieReader.duration;
}

#pragma mark - Public
- (void)seekToTime:(CMTime)time{
    [self.movieReader seekToTime:time];
    [self process];
}

#pragma mark - VGMovieDataReaderDelegate
- (void)movieHasUpdatedPixelBuffer:(CVPixelBufferRef _Nullable)pixelBuffer {
    [self.outputFrameBuffer use];
    [self.render render:pixelBuffer];
    glFinish();
}

- (void)movieLoadFail {
    NSLog(@"加载视频失败");
}

- (void)movieLoadSuccessWithRotation:(CGFloat)rotation presentationSize:(CGSize)presentationSize {
    if (self.outputFrameBuffer == nil){
        self.outputFrameBuffer = [[VGFrameBuffer alloc]initWithSize:presentationSize];
    }
    [self.render prepareWithRotation:rotation videoSize:presentationSize];
}

@end
