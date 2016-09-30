//
//  UIView+RCDDanmaku.m
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "UIView+RCDDanmaku.h"
#import "RCDDanmaku.h"
#import "RCDDanmakuInfo.h"
#import "RCDDanmakuManager.h"

#define X(view) view.frame.origin.x
#define Y(view) view.frame.origin.y
#define Width(view) view.frame.size.width
#define Height(view) view.frame.size.height
#define Left(view) X(view)
#define Right(view) (X(view) + Width(view))
#define Top(view) Y(view)
#define Bottom(view) (Y(view) + Height(view))
#define CenterX(view) (Left(view) + Right(view))/2
#define CenterY(view) (Top(view) + Bottom(view))/2

static NSTimeInterval const timeMargin = 0.5;

@implementation UIView (RCDDanmaku)
#pragma mark - perpare
- (void)prepareDanmakus:(NSArray *)danmakus
{
    RCDanmakuManager.maxIndex = [danmakus count];
    RCDanmakuManager.danmakus = [[danmakus sortedArrayUsingComparator:^NSComparisonResult(RCDDanmaku* obj1, RCDDanmaku* obj2) {
        if (obj1.timePoint > obj2.timePoint) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }] mutableCopy];
    
    
}

- (void)getCurrentTime
{
    //    NSLog(@"getCurrentTime---------");
    
    if (RCDanmakuManager.boolIsShowWithTime) {
        
        
        if([RCDanmakuManager.delegate danmakuViewIsBuffering:self]) return;
        
        [RCDanmakuManager.subDanmakuInfos enumerateObjectsUsingBlock:^(RCDDanmakuInfo* obj, NSUInteger idx, BOOL *stop) {
            NSTimeInterval leftTime = obj.leftTime;
            leftTime -= timeMargin;
            obj.leftTime = leftTime;
        }];
        
        [RCDanmakuManager.currentDanmakus removeAllObjects];
        NSTimeInterval timeInterval = [RCDanmakuManager.delegate danmakuViewGetPlayTime:self];
        NSString* timeStr = [NSString stringWithFormat:@"%0.1f", timeInterval];
        timeInterval = timeStr.floatValue;
        
        [RCDanmakuManager.danmakus enumerateObjectsUsingBlock:^(RCDDanmaku* obj, NSUInteger idx, BOOL *stop) {
            if (obj.timePoint >= timeInterval && obj.timePoint < timeInterval + timeMargin) {
                [RCDanmakuManager.currentDanmakus addObject:obj];
                NSLog(@"%f----%f--%zd", timeInterval, obj.timePoint, idx);
            }else if( obj.timePoint > timeInterval){
                *stop = YES;
            }
        }];
    }else{
        
        for (int i = 0 ; i < RCDanmakuManager.maxShowLineCount; i++) {
            RCDDanmakuInfo* Info = RCDanmakuManager.linesDict[@(i)];
            Info.leftTime -= timeMargin;
        }
        
        [RCDanmakuManager.currentDanmakus removeAllObjects];
        for (int i = 0; i <3; i++) {
            RCDanmakuManager.index = [self getNextIndex];
            [RCDanmakuManager.currentDanmakus addObject:RCDanmakuManager.danmakus[RCDanmakuManager.index]];
        }
    }
    NSLog(@"_________________%ld________________",[RCDanmakuManager.danmakus count]);
    if (RCDanmakuManager.currentDanmakus.count > 0) {
        for (RCDDanmaku* danmaku in RCDanmakuManager.currentDanmakus) {
            [self playDanmaku:danmaku];
        }
    }
    
    [RCDanmakuManager.delegate danmakuViewGetPlayTime:self];
    
}
- (NSInteger)getNextIndex{
    RCDanmakuManager.index++;
    if (RCDanmakuManager.index >= RCDanmakuManager.maxIndex) {
        RCDanmakuManager.index = 0;
    }
    
    return RCDanmakuManager.index;
}

- (void)playDanmaku:(RCDDanmaku *)danmaku
{
    NSLog(@"总弹幕数%zd",RCDanmakuManager.danmakus.count);
    UILabel* playerLabel = [[UILabel alloc] init];
    playerLabel.attributedText = danmaku.contentStr;
    [playerLabel sizeToFit];
    [self addSubview:playerLabel];
    playerLabel.backgroundColor = [UIColor clearColor];
    //    self.playingLabel = playerLabel;
    switch (danmaku.position) {
        case RCDDanmakuPositionNone:
            [self playFromRightDanmaku:danmaku playerLabel:playerLabel];
            break;
            
        case RCDDanmakuPositionCenterTop:
        case RCDDanmakuPositionCenterBottom:
            [self playCenterDanmaku:danmaku playerLabel:playerLabel];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - center top \ bottom
- (void)playCenterDanmaku:(RCDDanmaku *)danmaku playerLabel:(UILabel *)playerLabel
{
    NSAssert(RCDanmakuManager.centerDuration && RCDanmakuManager.maxCenterLineCount, @"如果要使用中间弹幕 必须先设置中间弹幕的时间及最大行数");
    
    RCDDanmakuInfo* newInfo = [[RCDDanmakuInfo alloc] init];
    newInfo.playLabel = playerLabel;
    newInfo.leftTime = RCDanmakuManager.centerDuration;
    newInfo.danmaku = danmaku;
    
    NSMutableDictionary* centerDict = nil;
    
    if (danmaku.position == RCDDanmakuPositionCenterTop) {
        centerDict = RCDanmakuManager.centerTopLinesDict;
    }else{
        centerDict = RCDanmakuManager.centerBottomLinesDict;
    }
    
    NSInteger valueCount = centerDict.allKeys.count;
    if (valueCount == 0) {
        newInfo.lineCount = 0;
        [self addCenterAnimation:newInfo centerDict:centerDict];
        return;
    }
    for (int i = 0; i<valueCount; i++) {
        RCDDanmakuInfo* oldInfo = centerDict[@(i)];
        if (!oldInfo) break;
        if (![oldInfo isKindOfClass:[RCDDanmakuInfo class]]) {
            newInfo.lineCount = i;
            [self addCenterAnimation:newInfo centerDict:centerDict];
            break;
        }else if (i == valueCount - 1){
            if (valueCount < RCDanmakuManager.maxCenterLineCount) {
                newInfo.lineCount = i+1;
                [self addCenterAnimation:newInfo centerDict:centerDict];
            }else{
                [RCDanmakuManager.danmakus removeObject:danmaku];
                [playerLabel removeFromSuperview];
                NSLog(@"同一时间评论太多--排不开了--------------------------");
            }
        }
    }
    
}

- (void)addCenterAnimation:(RCDDanmakuInfo *)info  centerDict:(NSMutableDictionary *)centerDict
{
    
    UILabel* label = info.playLabel;
    NSInteger lineCount = info.lineCount;
    
    if (info.danmaku.position == RCDDanmakuPositionCenterTop) {
        label.frame = CGRectMake((Width(self) - Width(label)) * 0.5, (RCDanmakuManager.lineHeight + RCDanmakuManager.lineMargin) * lineCount, Width(label), Height(label));
    }else{
        label.frame = CGRectMake((Width(self) - Width(label)) * 0.5, Height(self) - Height(label) - (RCDanmakuManager.lineHeight + RCDanmakuManager.lineMargin) * lineCount, Width(label), Height(label));
    }
    
    
    centerDict[@(lineCount)] = info;
    [RCDanmakuManager.subDanmakuInfos addObject:info];
    
    [self performCenterAnimationWithDuration:info.leftTime danmakuInfo:info ];
}

- (void)performCenterAnimationWithDuration:(NSTimeInterval)duration danmakuInfo:(RCDDanmakuInfo *)info
{
    UILabel* label = info.playLabel;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(RCDanmakuManager.isPauseing) return ;
        
        if (info.danmaku.position == RCDDanmakuPositionCenterBottom) {
            RCDanmakuManager.centerBottomLinesDict[@(info.lineCount)] = @(0);
        }else{
            RCDanmakuManager.centerTopLinesDict[@(info.lineCount)] = @(0);
        }
        
        [label removeFromSuperview];
        [RCDanmakuManager.subDanmakuInfos removeObject:info];
    });
}


#pragma mark - from right
- (void)playFromRightDanmaku:(RCDDanmaku *)danmaku playerLabel:(UILabel *)playerLabel
{
    
    RCDDanmakuInfo* newInfo = [[RCDDanmakuInfo alloc] init];
    newInfo.playLabel = playerLabel;
    newInfo.leftTime = RCDanmakuManager.duration;
    newInfo.danmaku = danmaku;
    newInfo.lineCount = rand() % RCDanmakuManager.maxShowLineCount;
    
    playerLabel.frame = CGRectMake(Width(self), 0, Width(playerLabel), Height(playerLabel));
//    [self addAnimationToViewWithInfo:newInfo];
    
    
    NSInteger valueCount = RCDanmakuManager.linesDict.allKeys.count;
    if (valueCount == 0) {
        newInfo.lineCount = 0;
        [self addAnimationToViewWithInfo:newInfo];
        return;
    }
    
    for (int i = 0; i<valueCount; i++) {
        RCDDanmakuInfo* oldInfo = RCDanmakuManager.linesDict[@(i)];
        if (!oldInfo) break;
        if (![self judgeIsRunintoWithFirstDanmakuInfo:oldInfo behindLabel:playerLabel]) {
            newInfo.lineCount = i;
            [self addAnimationToViewWithInfo:newInfo];
            break;
        }else if (i == valueCount - 1){
            if (valueCount < RCDanmakuManager.maxShowLineCount) {
                
//                newInfo.lineCount = i+1;
                newInfo.lineCount = (i+rand())%RCDanmakuManager.maxShowLineCount;
                [self addAnimationToViewWithInfo:newInfo];
            }else{
                [RCDanmakuManager.danmakus removeObject:danmaku];
                [RCDanmakuManager.linesDict removeAllObjects];
                [playerLabel removeFromSuperview];
                NSLog(@"同一时间评论太多--排不开了--------------------------");
            }
        }
        else {
            newInfo.lineCount = rand()%RCDanmakuManager.maxShowLineCount;
//            newInfo.lineCount = i+1;
            [self addAnimationToViewWithInfo:newInfo];
        }
    }
    
}

- (void)addAnimationToViewWithInfo:(RCDDanmakuInfo *)info
{
    UILabel* label = info.playLabel;
    NSInteger lineCount = info.lineCount;
    
    label.frame = CGRectMake(Width(self), (RCDanmakuManager.lineHeight + RCDanmakuManager.lineMargin) * lineCount, Width(label), Height(label));
    
    [RCDanmakuManager.subDanmakuInfos addObject:info];
    RCDanmakuManager.linesDict[@(lineCount)] = info;
    
    [self performAnimationWithDuration:info.leftTime danmakuInfo:info];
}

- (void)performAnimationWithDuration:(NSTimeInterval)duration danmakuInfo:(RCDDanmakuInfo *)info
{
    RCDanmakuManager.isPlaying = YES;
    RCDanmakuManager.isPauseing = NO;
    
    UILabel* label = info.playLabel;
    CGRect endFrame = CGRectMake(-Width(label), Y(label), Width(label), Height(label));
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        label.frame = endFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [label removeFromSuperview];
            [RCDanmakuManager.subDanmakuInfos removeObject:info];
            [RCDanmakuManager.danmakus removeObject:info.danmaku];
        }
        NSLog(@"count %zd",RCDanmakuManager.danmakus.count);
    }];
}

// 检测碰撞 -- 默认从右到左
- (BOOL)judgeIsRunintoWithFirstDanmakuInfo:(RCDDanmakuInfo *)info behindLabel:(UILabel *)last
{
    UILabel* firstLabel = info.playLabel;
    CGFloat firstSpeed = [self getSpeedFromLabel:firstLabel];
    CGFloat lastSpeed = [self getSpeedFromLabel:last];
    
    
    //    CGRect firstFrame = info.labelFrame;
    CGFloat firstFrameRight = info.leftTime * firstSpeed;
    
    if(info.leftTime <= 1) return NO;
    
    
    
    if(Left(last) - firstFrameRight > 10) {
        
        if( lastSpeed <= firstSpeed)
        {
            return NO;
        }else{
            CGFloat lastEndLeft = Left(last) - lastSpeed * info.leftTime;
            if (lastEndLeft >  10) {
                return NO;
            }
        }
    }
    
    return YES;
}

// 计算速度
- (CGFloat)getSpeedFromLabel:(UILabel *)label
{
    return (self.bounds.size.width + label.bounds.size.width) / RCDanmakuManager.duration;
}

#pragma mark - 公共方法

- (BOOL)isPrepared
{
    NSAssert(RCDanmakuManager.duration && RCDanmakuManager.maxShowLineCount && RCDanmakuManager.lineHeight, @"必须先设置弹幕的时间\\最大行数\\弹幕行高");
    if (RCDanmakuManager.danmakus.count && RCDanmakuManager.lineHeight && RCDanmakuManager.duration && RCDanmakuManager.maxShowLineCount) {
        return YES;
    }
    return NO;
}

- (void)start
{
    
    if(RCDanmakuManager.isPauseing) [self resume];
    
    if ([self isPrepared]) {
        if (!RCDanmakuManager.timer) {
            RCDanmakuManager.timer = [NSTimer timerWithTimeInterval:timeMargin target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:RCDanmakuManager.timer forMode:NSRunLoopCommonModes];
            [RCDanmakuManager.timer fire];
        }
    }
}
- (void)pause
{
    if(!RCDanmakuManager.timer || !RCDanmakuManager.timer.isValid) return;
    
    RCDanmakuManager.isPauseing = YES;
    RCDanmakuManager.isPlaying = NO;
    
    [RCDanmakuManager.timer invalidate];
    RCDanmakuManager.timer = nil;
    
    for (UILabel* label in self.subviews) {
        
        CALayer *layer = label.layer;
        CGRect rect = label.frame;
        if (layer.presentationLayer) {
            rect = ((CALayer *)layer.presentationLayer).frame;
        }
        label.frame = rect;
        [label.layer removeAllAnimations];
    }
}
- (void)resume
{
    if( ![RCDanmakuManager isPrepared] || RCDanmakuManager.isPlaying || !RCDanmakuManager.isPauseing) return;
    for (RCDDanmakuInfo* info in RCDanmakuManager.subDanmakuInfos) {
        if (info.danmaku.position == RCDDanmakuPositionNone) {
            [self performAnimationWithDuration:info.leftTime danmakuInfo:info];
        }else{
            RCDanmakuManager.isPauseing = NO;
            [self performCenterAnimationWithDuration:info.leftTime danmakuInfo:info];
        }
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeMargin * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start];
    });
}
- (void)stop
{
    RCDanmakuManager.isPauseing = NO;
    RCDanmakuManager.isPlaying = NO;
    
    [RCDanmakuManager.timer invalidate];
    RCDanmakuManager.timer = nil;
    [RCDanmakuManager.danmakus removeAllObjects];
    RCDanmakuManager.linesDict = nil;
}

- (void)clear
{
    [RCDanmakuManager.timer invalidate];
    RCDanmakuManager.timer = nil;
    RCDanmakuManager.linesDict = nil;
    RCDanmakuManager.isPauseing = YES;
    RCDanmakuManager.isPlaying = NO;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)sendDanmakuSource:(RCDDanmaku *)danmaku
{
    //如果允许过量加载demo，就不进行弹幕的缓存，
    if(RCDanmakuManager.isAllowOverLoad){
        [self playDanmaku:danmaku];
    }else {
        [RCDanmakuManager.danmakus addObject:danmaku];
        [self playOverLoadDanmaku];
    }
    
}

- (void)playOverLoadDanmaku {
    if (!RCDanmakuManager.timer) {
        RCDanmakuManager.timer = [NSTimer timerWithTimeInterval:timeMargin target:self selector:@selector(sendOverLoadDanmaku) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:RCDanmakuManager.timer forMode:NSRunLoopCommonModes];
        [RCDanmakuManager.timer fire];
    }
}

- (void)sendOverLoadDanmaku {
    RCDanmakuManager.total ++;
    if(RCDanmakuManager.danmakus.count > 0){
        [self playDanmaku:RCDanmakuManager.danmakus[0]];
    }
}
@end
