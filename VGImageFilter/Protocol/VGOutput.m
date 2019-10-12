//
//  VGOutput.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGOutput.h"

@interface VGOutput()
@end

@implementation VGOutput
- (instancetype)init
{
    self = [super init];
    if (self) {
        _targetArray = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Public
- (void)addTarget:(id<VGInputProtocol>)target{
    [self.targetArray addObject:target];
}

- (void)removeTarget:(id<VGInputProtocol>)target{
    [self.targetArray removeObject:target];
}

- (void)process{
    __weak typeof(self) weakSelf = self;
    [self.targetArray enumerateObjectsUsingBlock:^(id <VGInputProtocol> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateInputWithFrameBuffer:weakSelf.outputFrameBuffer];
    }];
}
@end
