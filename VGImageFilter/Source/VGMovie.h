//
//  VGMovie.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGOutput.h"
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface VGMovie : VGOutput
@property(nonatomic, assign, readonly)CMTime duration;
- (instancetype)initWithPath:(NSString *)path;
- (void)seekToTime:(CMTime)time;
@end

NS_ASSUME_NONNULL_END
