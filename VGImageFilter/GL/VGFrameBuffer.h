//
//  VGFrameBuffer.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/12.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface VGFrameBuffer : NSObject
@property(nonatomic, assign, readonly)CGSize renderSize;
- (instancetype)initWithSize:(CGSize)size;

- (void)use;
- (GLuint)useTexture;
- (void)clean;
@end

NS_ASSUME_NONNULL_END
