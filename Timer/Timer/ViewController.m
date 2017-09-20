//
//  ViewController.m
//  Timer
//
//  Created by 李斌 on 2017/9/20.
//  Copyright © 2017年 李斌. All rights reserved.
//

#import "ViewController.h"
#import "LBTimer.h"


@interface ViewController ()

@property (nonatomic, assign) int64_t count;
@property (nonatomic, assign) int64_t timeCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            LBTimer *lbtimer = [[LBTimer alloc] init];
//            [lbtimer registerTimer:[self description] period:3 delegate:self action:@selector(myTime:)];
//            [lbtimer start];
//    });
//    

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:3 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
        NSRunLoop *runloop  = [NSRunLoop currentRunLoop];
        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
        [runloop run];
        
    });
    
    
//    [[NSRunLoop currentRunLoop] run];
    
    
    
}


- (void)myTime:(LBTimer *)timer{
    _count++;
    
    NSLog(@"count == %lld",_count);
}

- (void)timerFire:(NSTimer*)timer{
    _timeCount++;
    NSLog(@"_timeCount == %lld",_timeCount);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
