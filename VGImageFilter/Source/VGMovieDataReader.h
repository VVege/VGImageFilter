//
//  VGMovieDataReader.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VGMovieDataReaderDelegate <NSObject>
- (void)movieLoadSuccessWithRotation:(CGFloat)rotation presentationSize:(CGSize)presentationSize;
- (void)movieLoadFail;
- (void)movieHasUpdatedPixelBuffer:(CVPixelBufferRef _Nullable)pixelBuffer;
@end
NS_ASSUME_NONNULL_BEGIN

@interface VGMovieDataReader : NSObject

@property(nonatomic, assign)id<VGMovieDataReaderDelegate>delegate;
@property(nonatomic, readonly)CMTime duration;

- (instancetype)initWithPath:(NSString *)path;
- (void)seekToTime:(CMTime)time;
@end

NS_ASSUME_NONNULL_END
