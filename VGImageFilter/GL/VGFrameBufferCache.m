//
//  VGFrameBufferCache.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/19.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGFrameBufferCache.h"
#import "VGFrameBuffer.h"

@interface VGFrameBufferCache()
@property(nonatomic, strong)NSMutableArray *caches;
@end
@implementation VGFrameBufferCache
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.caches = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

#pragma mark - Private
- (void)fillCacheWithIndex:(NSInteger)index{
    while (self.caches.count < index + 1) {
        VGFrameBuffer *newFrameBuffer = [[VGFrameBuffer alloc]initWithSize:CGSizeZero];
        [self.caches addObject:newFrameBuffer];
    }
}

#pragma mark - Public
- (VGFrameBuffer *)avalibleFrameBuffer{
    
}
@end
