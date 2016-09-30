//
//  RCDDanmaku.h
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    RCDDanmakuPositionNone = 0,
    RCDDanmakuPositionCenterTop,
    RCDDanmakuPositionCenterBottom
} RCDDanmakuPosition;

@interface RCDDanmaku : NSObject
// 对应视频的时间戳
@property(nonatomic, assign) NSTimeInterval timePoint;
// 弹幕内容
@property(nonatomic, copy) NSAttributedString* contentStr;
// 弹幕类型(如果不设置 默认情况下只是从右到左滚动)
@property(nonatomic, assign) RCDDanmakuPosition position;
@end
