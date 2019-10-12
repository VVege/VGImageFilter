//
//  VGVideoFilter.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/6/21.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGImageFilter.h"
#import "VGInputProtocol.h"

typedef NS_ENUM(NSInteger, VGAlphaBackgroundColor) {
    VGAlphaBackgroundColorBlack,
    VGAlphaBackgroundColorGreen,
};

NS_ASSUME_NONNULL_BEGIN

@interface VGAlphaBackgroundVideoFilter : VGImageFilter <VGInputProtocol>
- (instancetype)initWithColor:(VGAlphaBackgroundColor)color;
@end

NS_ASSUME_NONNULL_END
