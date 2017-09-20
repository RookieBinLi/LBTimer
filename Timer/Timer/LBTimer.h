//
//  LBTimer.h
//  Timer
//
//  Created by 李斌 on 2017/9/20.
//  Copyright © 2017年 李斌. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^Time_CallBack)(NSString *name);

@interface LBTimer : NSObject

/*
  注册时间管理器
  name:标识 唯一
  period:周期时间
*/

- (void)registerTimer:(NSString *)name period:(int64_t)period delegate:(id)delegate action:(SEL)action;

/*
  注销时间管理器
  name:标识 唯一
  period:周期时间
*/

- (void)unregisterTimer:(NSString *)name;

- (void)start;

- (void)stop;


@end
