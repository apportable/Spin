//
//  CCGLQueue.h
//  CCGLQueue
//
//  Created by Philippe Hausler on 5/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

@interface CCGLQueue : NSThread

+ (instancetype)mainQueueWithAPI:(EAGLRenderingAPI)api;
+ (instancetype)queueWithAPI:(EAGLRenderingAPI)api;
- (instancetype)initWithAPI:(EAGLRenderingAPI)api;
- (void)addOperation:(void (^)(EAGLContext *))block;
- (void)flush;

@end
