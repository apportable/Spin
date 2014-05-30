//
//  CCGLQueue.m
//  CCGLQueue
//
//  Created by Philippe Hausler on 5/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCGLQueue.h"
#import <libkern/OSAtomic.h>

static CCGLQueue *mainQueues[4] = { nil, nil, nil , nil };
static OSSpinLock mainQueueLock = OS_SPINLOCK_INIT;

@implementation CCGLQueue {
    BOOL _isMainQueue;
    EAGLRenderingAPI _api;
    EAGLContext *_ctx;
    CFRunLoopRef _runLoop;
    CFRunLoopSourceRef _source;
    NSMutableArray *_operations;
    OSSpinLock _operationLock;
}

- (void)dealloc
{
    if (_source) {
        CFRelease(_source);
    }
    OSSpinLockLock(&_operationLock);
    _operations = nil;
    OSSpinLockUnlock(&_operationLock);
}

- (instancetype)initWithAPI:(EAGLRenderingAPI)api {
    self = [super init];
    
    if (self) {
        _api = api;
        _operations = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (instancetype)initWithAPI:(EAGLRenderingAPI)api mainQueue:(BOOL)isMainQueue {
    self = [self initWithAPI:api];
    
    if (self) {
        _isMainQueue = isMainQueue;
    }
    
    return self;
}

+ (instancetype)mainQueueWithAPI:(EAGLRenderingAPI)api {
    OSSpinLockLock(&mainQueueLock);
    if (mainQueues[api] == nil) {
        mainQueues[api] = [[CCGLQueue alloc] initWithAPI:api mainQueue:YES];
    }
    OSSpinLockUnlock(&mainQueueLock);
    return mainQueues[api];
}

+ (instancetype)queueWithAPI:(EAGLRenderingAPI)api {
    return [[CCGLQueue alloc] initWithAPI:api];
}

- (EAGLContext *)context {
    return _ctx;
}

- (void)drain {
    while (true) {
        OSSpinLockLock(&_operationLock);
        void (^block)(EAGLContext *) = [_operations firstObject];
        if (block) {
            [_operations removeObjectAtIndex:0];
        }
        OSSpinLockUnlock(&_operationLock);
        if (block) {
            block(_ctx);
        } else {
            break;
        }
    }
}

static void perform(void *info) {
    [(__bridge CCGLQueue *)info drain];
}

- (void)main {
    CFRunLoopSourceContext ctx = {
        .version = 0,
        .info = (__bridge void *)self,
        .perform = &perform
    };
    _runLoop = CFRunLoopGetCurrent();
    _source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &ctx);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), _source, kCFRunLoopDefaultMode);
    if (_isMainQueue) {
        _ctx = [[EAGLContext alloc] initWithAPI:_api];
    } else {
        OSSpinLockLock(&mainQueueLock);
        _ctx = [[EAGLContext alloc] initWithAPI:_api sharegroup:[[mainQueues[_api] context] sharegroup]];
        OSSpinLockUnlock(&mainQueueLock);
    }
    
    [EAGLContext setCurrentContext:_ctx];
    
    while (true) {
        CFRunLoopRun();
    }
}

- (void)cancel {
    if (!_isMainQueue) {
        CFRunLoopRemoveSource(_runLoop, _source, kCFRunLoopDefaultMode);
        CFRunLoopStop(_runLoop);
    }
}

- (void)addOperation:(void (^)(EAGLContext *))block {
    OSSpinLockLock(&_operationLock);
    [_operations addObject:block];
    OSSpinLockUnlock(&_operationLock);
}

- (void)flush {
    if (CFRunLoopGetCurrent() == _runLoop) {
        [self drain];
    } else {
        CFRunLoopSourceSignal(_source);
        CFRunLoopWakeUp(_runLoop);
    }
}

@end
