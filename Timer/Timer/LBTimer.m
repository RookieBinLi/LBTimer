//
//  LBTimer.m
//  Timer
//
//  Created by 李斌 on 2017/9/20.
//  Copyright © 2017年 李斌. All rights reserved.
//

#import "LBTimer.h"

#define kTime_Interval 1

@interface CallBackInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id  delegate;
@property (nonatomic, assign) int64_t period;
@property (nonatomic, assign) int64_t fired;

@end

@implementation CallBackInfo

- (void)dealloc {
    self.delegate = nil;
    self.selector = nil;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
    }
    return self;
}

@end

@interface LBTimer ()
{
    NSMutableArray *_callBacks;
    NSTimer *_timer;
    CFRunLoopRef _runloop;
    BOOL _stop;
}

@end

@implementation LBTimer

- (void)dealloc {


}

- (instancetype)init {
    if (self = [super init]) {
        _callBacks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)registerTimer:(NSString *)name period:(int64_t)period delegate:(id)delegate action:(SEL)action {
  
    @synchronized (self) {
   
        for (int i = 0; i < [_callBacks count]; i++) {
            
            CallBackInfo *callBackInfo = [_callBacks objectAtIndex:i];
            if ([callBackInfo.name isEqualToString:name]) {
                [_callBacks removeObjectAtIndex:i];
                break;
            }
        }
        
        CallBackInfo *callBackInfo = [[CallBackInfo alloc] init];
        [callBackInfo setSelector:action];
        [callBackInfo setPeriod:period];
        [callBackInfo setName:name];
        [callBackInfo setDelegate:delegate];
        [_callBacks addObject:callBackInfo];
    }
}

- (void)unregisterTimer:(NSString *)name {
 
    @synchronized (self) {
   
        for (int i = 0; i < [_callBacks count]; i++) {
            
            CallBackInfo *callbackInfo = [_callBacks objectAtIndex:i];
            if ([callbackInfo.name isEqualToString:name]) {
                 //取消执行函数
                 [NSObject cancelPreviousPerformRequestsWithTarget:callbackInfo.delegate selector:callbackInfo.selector object:nil];
                 [_callBacks removeObjectAtIndex:i];
                 break;
            }
        }
    }
}

- (void)start {
    @synchronized (self) {
        _stop = NO;
        [NSThread detachNewThreadSelector:@selector(timerSheduleToRunloop) toTarget:self withObject:nil];
    }
}

- (void)stop {
    @synchronized (self) {
        _stop = YES;
        
        if (_runloop) {
            CFRunLoopStop(_runloop);
            [_callBacks removeAllObjects];
        }
    }
}

- (void)timerSheduleToRunloop {
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTime_Interval target:self selector:@selector(_onTimerFired:) userInfo:nil repeats:YES];
    //
    _runloop = CFRunLoopGetCurrent();
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRunLoopAddTimer(_runloop, (CFRunLoopTimerRef)_timer, kCFRunLoopDefaultMode);
    
    while (!_stop) {
        //用DefaultMode启动runloop 用指定的Mode启动，允许设置RunLoop最大时间（假无限循环），执行完毕是否退出
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
    }
    
    [_timer invalidate];
    _timer = nil;
    
    CFRunLoopRemoveTimer(_runloop, (CFRunLoopTimerRef)_timer, kCFRunLoopDefaultMode);
    CFRelease(source);
    _runloop = NULL;
}

- (void)_onTimerFired:(NSTimer *)timer {

    @synchronized (self) {
        int64_t now = time(NULL);
        
        for (int i = 0; i < [_callBacks count]; i++) {
            CallBackInfo *callBackInfo = [_callBacks objectAtIndex:i];
            if (callBackInfo.period+ callBackInfo.fired > now)
                continue;

            if ([callBackInfo.delegate respondsToSelector:callBackInfo.selector]) {
                [callBackInfo.delegate performSelectorOnMainThread:callBackInfo.selector withObject:nil waitUntilDone:NO];
            }
            
            callBackInfo.fired = time(NULL);
        }
        
        
    }
}


@end
