//
//  VGContext.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EAGLContext;
@interface VGContext : NSObject
+ (VGContext *)sharedContext;
@property(nonatomic, strong, readonly)EAGLContext *glContext;
@end

NS_ASSUME_NONNULL_END
