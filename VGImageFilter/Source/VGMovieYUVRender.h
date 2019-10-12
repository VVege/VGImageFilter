//
//  VGMovieYUVRender.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface VGMovieYUVRender : NSObject
- (void)prepareWithRotation:(CGFloat)rotation videoSize:(CGSize)videoSize;
- (void)render:(CVPixelBufferRef)pixelBuffer;
- (CGImageRef)image:(CVPixelBufferRef)pixelBuffer;
@end

NS_ASSUME_NONNULL_END
