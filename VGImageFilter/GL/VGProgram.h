//
//  VGProgram.h
//  VGImageFilter
//
//  Created by 周智伟 on 2019/6/18.
//  Copyright © 2019 vege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface VGProgram : NSObject
@property(nonatomic, assign, readonly)GLuint programId;
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag;
@end

NS_ASSUME_NONNULL_END
