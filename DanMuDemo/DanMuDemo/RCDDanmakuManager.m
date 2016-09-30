//
//  RCDDanmakuManager.m
//  DanMuDemo
//
//  Created by Sin on 16/9/26.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "RCDDanmakuManager.h"

@interface RCDDanmakuManager ()

@end

@implementation RCDDanmakuManager
+ (instancetype)sharedManager {
    static RCDDanmakuManager *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[self alloc]init];
    });
    return manger;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.index = 0;
        self.danmakus = [[NSMutableArray alloc]init];
        self.currentDanmakus = [[NSMutableArray alloc] init];
        self.subDanmakuInfos = [[NSMutableArray alloc]init];
        self.linesDict = [[NSMutableDictionary alloc]init];
        self.centerTopLinesDict = [[NSMutableDictionary alloc]init];
        self.centerBottomLinesDict = [[NSMutableDictionary alloc]init];
        self.duration = 6.5;
        self.centerDuration = 2.5;
        self.lineHeight = 25;
        self.maxShowLineCount = 15;
        self.maxCenterLineCount = 5;
        self.boolIsShowWithTime = YES;
        self.isAllowOverLoad = NO;
        self.total = 0;
    }
    return self;
}

@end
