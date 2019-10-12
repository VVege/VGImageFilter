//
//  VGInputProtocol.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VGFrameBuffer;
NS_ASSUME_NONNULL_BEGIN

@protocol VGInputProtocol <NSObject>
- (void)updateInputWithFrameBuffer:(VGFrameBuffer *)frameBuffer;
@end

NS_ASSUME_NONNULL_END
