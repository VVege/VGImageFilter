//
//  VGOutput.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGInputProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VGOutput : NSObject
@property(nonatomic, strong, readonly)NSMutableArray *targetArray;
@property(nonatomic, strong)VGFrameBuffer *outputFrameBuffer;
- (void)addTarget:(id<VGInputProtocol>)target;
- (void)removeTarget:(id<VGInputProtocol>)target;
- (void)process;
@end

NS_ASSUME_NONNULL_END
