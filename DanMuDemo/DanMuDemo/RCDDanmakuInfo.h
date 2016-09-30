//
//  RCDDanmakuInfo.h
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDDanmaku;

@interface RCDDanmakuInfo : NSObject
// 弹幕内容label
@property(nonatomic, weak) UILabel  *playLabel;
// 弹幕label frame
//@property(nonatomic, assign) CGRect labelFrame;
//
@property(nonatomic, assign) NSTimeInterval leftTime;
@property(nonatomic, strong) RCDDanmaku* danmaku;
@property(nonatomic, assign) NSInteger lineCount;
@end
