//
//  OBRefreshControl.m
//  OutbrainDemo
//
//  Created by Oded Regev on 1/7/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBRefreshControl.h"

#define BALL_UPDATE_INTERVAL 3

@implementation OBRefreshControl
{
    CALayer * _ballLayer;
    CADisplayLink * _ballDisplayLink;
    
    CGPoint _ballOffset;
    CGFloat _ballRotation;
}


#pragma mark - Init

- (void)initialize
{
    _ballLayer = [CALayer new];
    UIImage * ballImage = [UIImage imageNamed:@"logo-navbar"];
    _ballLayer.contents = (id)ballImage.CGImage;
    _ballLayer.bounds = CGRectMake(0, 0, 20.f, 20.f);
    _ballLayer.position = CGPointMake((self.bounds.size.width - _ballLayer.bounds.size.width) / 2.f, (self.bounds.size.height - _ballLayer.bounds.size.height) / 2.f);
    [self.layer addSublayer:_ballLayer];
    
    srand([[NSDate date] timeIntervalSince1970]);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self initialize]; return self; }

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self initialize]; return self; }


#pragma mark - Overrides

- (void)beginRefreshing
{
    [super beginRefreshing];
    [self beginRefreshAnimation];
}

- (void)beginRefreshAnimation
{
    if(!_ballDisplayLink)
    {
        NSInteger xOff = arc4random() % 15;
        NSInteger yOff = arc4random() % 15;
        
        xOff = MAX(xOff, 5.f);
        yOff = MAX(yOff, 5.f);
        
        
        _ballOffset = CGPointMake(xOff, yOff);
        _ballRotation = 0;
        
        _ballDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTimer:)];
        _ballDisplayLink.frameInterval = BALL_UPDATE_INTERVAL;
        [_ballDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)refreshTimer:(CADisplayLink *)timer
{
    CGRect ballFrame = _ballLayer.frame;
    
    CGFloat rotationInterval = M_PI_4;
    
    if(CGRectGetMaxX(ballFrame) >= self.bounds.size.width || CGRectGetMinX(ballFrame) <= 0)
    {
        // We hit the right or left wall.  Reverse x
        _ballOffset.x *= -1;
        rotationInterval*=-1;
    }
    
    if(CGRectGetMaxY(ballFrame) >= self.bounds.size.height || CGRectGetMinY(ballFrame) < 0)
    {
        // We hit a top or bottom wall.  Reverse y
        _ballOffset.y *= -1;
        rotationInterval*=-1;
    }
    
    CGPoint pos = _ballLayer.position;
    
    pos.x += _ballOffset.x;
    pos.y += _ballOffset.y;


    
    _ballRotation += rotationInterval;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:[timer duration] * [timer frameInterval]];
    _ballLayer.transform = CATransform3DMakeRotation(_ballRotation, 0, 0, 1);
    _ballLayer.position = pos;
    [CATransaction commit];
}

- (void)endRefreshing
{
    [super endRefreshing];
    if(_ballDisplayLink)
    {
        [_ballDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_ballDisplayLink invalidate];
        _ballDisplayLink = nil;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:.3f];
    _ballLayer.transform = CATransform3DIdentity;
    _ballLayer.position = CGPointMake((self.bounds.size.width - _ballLayer.bounds.size.width) / 2.f, (self.bounds.size.height - _ballLayer.bounds.size.height) / 2.f);
    [CATransaction commit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for(UIView * v in self.subviews)
    {
        v.alpha = 0;
    }
    
    if(self.isRefreshing && !_ballDisplayLink)
    {
        [self beginRefreshAnimation];
    } else if(!self.isRefreshing) {
        // Do my layout here
        _ballLayer.position = CGPointMake((self.bounds.size.width - _ballLayer.bounds.size.width) / 2.f, (self.bounds.size.height - _ballLayer.bounds.size.height) / 2.f);
    }
}


@end
