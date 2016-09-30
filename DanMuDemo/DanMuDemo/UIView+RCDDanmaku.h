//
//  UIView+RCDDanmaku.h
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDDanmaku;

@interface UIView (RCDanmaku)
- (void)prepareDanmakus:(NSArray *)danmakus;
// start 与 stop 对应  pause 与 resume 对应
- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

// 发送一个弹幕
- (void)sendDanmakuSource:(RCDDanmaku *)danmaku;
@end
