//
//  ViewController.m
//  DanMuDemo
//
//  Created by Sin on 16/9/23.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import "ViewController.h"
#import "UIView+RCDDanmaku.h"
#import "RCDDanmaku.h"
#import "RCDDanmakuManager.h"

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]

@interface ViewController ()
//@property (nonatomic,assign) BOOL isStop;
//@property (nonatomic,strong) UIView *liveView;
@property (nonatomic,assign) NSInteger total;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self sendDanMu];
    
//    self.isStop = NO;
//    [self liveView];
//    RCDanmakuManager.isAllowOverLoad = YES;
    UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50, 44)];
    startButton.backgroundColor = [UIColor greenColor];
    [startButton addTarget:self action:@selector(startDanmaku) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"start" forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    self.total = 0;
}

- (void)startDanmaku {
    //设置定时器，模仿直播聊天室里观众的发言
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(sendDanmaku) userInfo:nil repeats:YES];
}

- (void)sendDanmaku {
    self.total ++;
    //发送一个弹幕
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:@"text--test---t-est" attributes:@{NSForegroundColorAttributeName : kRandomColor}];
    if(rand()%5==0){
        danmaku.position = RCDDanmakuPositionCenterTop;
    }else if (rand()%7==0){
        danmaku.position = RCDDanmakuPositionCenterBottom;
    }
    [self.view sendDanmakuSource:danmaku];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
