//
//  ViewController.m
//  BallAnimation
//
//  Created by Mr.Yang on 15/4/14.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ViewController.h"

/**
 *  教程
 *  http://www.cocoachina.com/ios/20150106/10839.html
 *  时间线性变化函数地址
 *  http://robertpenner.com/easing/
 */


static int shouldDisplayLink;
@interface ViewController ()
@property (nonatomic) UIImageView *ballView;
@property (nonatomic) NSTimeInterval timeOffset;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) CADisplayLink *displayLink;
@property (nonatomic, strong)   id fromValue;
@property (nonatomic, strong)   id toValue;
@property (nonatomic, assign)   CFTimeInterval lastAnimateTime;

@end


float interpolate(float from, float to, float time)
{
    return (to - from) * time + from;
}

float bounceEaseOut(float t)
{
    if (t < 4/11.0) {
        return (121 * t * t)/16.0;
    } else if (t < 8/11.0) {
        return (363/40.0 * t * t) - (99/10.0 * t) + 17/5.0;
    } else if (t < 9/10.0) {
        return (4356/361.0 * t * t) - (35442/1805.0 * t) + 16061/1805.0;
    }
    return (54/5.0 * t * t) - (513/25.0 * t) + 268/25.0;
}

@implementation ViewController

- (id)interpolateFromValue:(id)fromValue toValue:(id)toValue time:(float)time
{
    if ([fromValue isKindOfClass:[NSValue class]]) {
        //get type
        const char *type = [(NSValue *)fromValue objCType];
        if (strcmp(type, @encode(CGPoint)) == 0) {
            CGPoint from = [fromValue CGPointValue];
            CGPoint to = [toValue CGPointValue];
            CGPoint result = CGPointMake(interpolate(from.x, to.x, time), interpolate(from.y, to.y, time));
            return [NSValue valueWithCGPoint:result];
        }
    }
    //provide safe default implementation
    return (time < 0.5)? fromValue: toValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    shouldDisplayLink = 1;
    
    self.ballView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball"]];
    self.ballView.frame = CGRectMake(0, 0, 50, 50);
    self.ballView.center = CGPointMake(150, 150);
    [self.view addSubview:self.ballView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 50, 120, 50);
    [self.view addSubview:button];
    [button setTitle:@"开始动画" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doAnimation) forControlEvents:UIControlEventTouchUpInside];

    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(200, 50, 120, 50);
    [self.view addSubview:button1];
    [button1 setTitle:@"开始动画(Dis)" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(caDoAnimation) forControlEvents:UIControlEventTouchUpInside];
}

- (void)caDoAnimation
{
    shouldDisplayLink = 1;
    
    [self ballAnimation];
}

- (void)doAnimation
{
    shouldDisplayLink = 0;
    
    [self ballAnimation];
}

- (void)ballAnimation
{
    self.ballView.center = CGPointMake(150, 150);
    self.duration = 3.0f;
    self.timeOffset = .0f;
    
    self.fromValue = [NSValue valueWithCGPoint:CGPointMake(150, 150)];
    self.toValue = [NSValue valueWithCGPoint:CGPointMake(150, 280)];
    
    if (shouldDisplayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animated:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
    }else {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f target:self selector:@selector(animated:) userInfo:nil repeats:YES];
    }
    
}

- (void)animated:(NSTimer *)timer
{

    if (shouldDisplayLink) {
        CFTimeInterval thisStep = CACurrentMediaTime();
        CFTimeInterval duration = thisStep - self.lastAnimateTime;
        self.lastAnimateTime = thisStep;
        self.timeOffset = MIN(self.timeOffset + duration, self.duration);
    }else {
        self.timeOffset = MIN(self.timeOffset + 1 / 60.0f, self.duration);
    }
    
    float time = self.timeOffset / self.duration;
    
    
    time = bounceEaseOut(time);
    
    id position = [self interpolateFromValue:self.fromValue toValue:self.toValue time:time];
    
    self.ballView.center = [position CGPointValue];
    
    if (self.timeOffset >= self.duration) {
        [self.timer invalidate];
        self.timer = nil;
        self.ballView.center = CGPointMake(150, 150);
    }
    
}


@end
