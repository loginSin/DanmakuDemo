//
//  RCDDanmakuManager.h
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RCDanmakuManager [RCDDanmakuManager sharedManager]


@protocol RCDDanmakuManagerDelegate <NSObject>

@required
// 获取视频播放时间
- (NSTimeInterval)danmakuViewGetPlayTime:(UIView *)danmakuView;
// 加载视频中
- (BOOL)danmakuViewIsBuffering:(UIView *)danmakuView;

@end

@interface RCDDanmakuManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<RCDDanmakuManagerDelegate> delegate;
@property (nonatomic, assign) BOOL isPrepared;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPauseing;

// 以下属性都是必须配置的--------
// 弹幕动画时间
@property (nonatomic, assign) CGFloat duration;
// 中间上边/下边弹幕动画时间
@property (nonatomic, assign) CGFloat centerDuration;
// 弹幕弹道高度
@property (nonatomic, assign) CGFloat lineHeight;
// 弹幕弹道之间的间距
@property (nonatomic, assign) CGFloat lineMargin;

// 弹幕弹道最大行数
@property (nonatomic, assign) NSInteger maxShowLineCount;

// 弹幕弹道中间上边/下边最大行数
@property (nonatomic, assign) NSInteger maxCenterLineCount;
// 按时间显示或者数组循环显示
@property (nonatomic) BOOL boolIsShowWithTime;
//是否允许过量加载弹幕，如果为yes，那么不做弹幕缓存，来多少弹幕，就直接加载多少
@property (nonatomic,assign) BOOL isAllowOverLoad;

// 以上属性都是必须配置的--------//

//inner property
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSMutableArray* danmakus;
@property(nonatomic, strong) NSMutableArray* currentDanmakus;
@property(nonatomic, strong) NSMutableArray* subDanmakuInfos;

@property(nonatomic, strong) NSMutableDictionary* linesDict;
@property(nonatomic, strong) NSMutableDictionary* centerTopLinesDict;
@property(nonatomic, strong) NSMutableDictionary* centerBottomLinesDict;

@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger maxIndex;
@property (nonatomic) NSInteger total;
@property (nonatomic,strong) dispatch_queue_t rc_danmaku_manager_queue;
@end
