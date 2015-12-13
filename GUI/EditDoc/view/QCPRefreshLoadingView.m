//
//  QCPRefreshLoadingView.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/12/11.
//  Copyright © 2015年 R_style Man. All rights reserved.
//

#import "QCPRefreshLoadingView.h"

@interface QCPRefreshLoadingView () {
  QCPRefreshLoadingLayer *_redLayer, *_yellowLayer, *_greenLayer;
}

@end

@implementation QCPRefreshLoadingView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f];
    
    _redLayer = [[QCPRefreshLoadingLayer alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 5, self.frame.size.height, 10, 10)];
    _redLayer.layerType = QCPRefreshLayerRed;
    [self.layer addSublayer:_redLayer];
    
    _yellowLayer = [[QCPRefreshLoadingLayer alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 5, self.frame.size.height, 10, 10)];
    _yellowLayer.layerType = QCPRefreshLayerYellow;
    [self.layer addSublayer:_yellowLayer];
    
    _greenLayer = [[QCPRefreshLoadingLayer alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 5, self.frame.size.height, 10, 10)];
    _greenLayer.layerType = QCPRefreshLayerGreen;
    [self.layer addSublayer:_greenLayer];
  }
  return self;
}

- (void)showInView:(UIScrollView *)scrollView
{
  self.frame = CGRectMake(0, MIN(-100, -100 + (scrollView.contentOffset.y + 164)), scrollView.frame.size.width, 100);
//  [self addPositionAnimation];
  if (scrollView.contentOffset.y < (-64 - 40)) {
    CGPoint posion = _redLayer.position;
    CGPoint newPosion = CGPointMake(posion.x, MAX(40, self.frame.size.height + 64 + scrollView.contentOffset.y));
    _redLayer.position = newPosion;
  } else {
    
  }
  
//  if (_redLayer.position.y == 40) {
//    CGPoint posion = _yellowLayer.position;
//    CGPoint newPosion = CGPointMake(posion.x, MAX(60, self.frame.size.height + 64 + scrollView.contentOffset.y + 20));
//    _yellowLayer.position = newPosion;
//  } else {
//    
//  }
//  
//  if (_yellowLayer.position.y == 60) {
//    CGPoint posion = _greenLayer.position;
//    CGPoint newPosion = CGPointMake(posion.x, MAX(80, self.frame.size.height + 64 + scrollView.contentOffset.y + 40));
//    _greenLayer.position = newPosion;
//  } else {
//    
//  }
  

  
}

- (void)addPositionAnimation
{
  [_redLayer addAnimationToPositionY:10 withKey:@"red.transform"];
  [_yellowLayer addAnimationToPositionY:30 withKey:@"yellow.transform"];
  [_greenLayer addAnimationToPositionY:50 withKey:@"green.transform"];
}

- (void)rotate
{
  
}

@end

@implementation QCPRefreshLoadingLayer

- (id)init
{
  self = [super init];
  if (self) {
    self.masksToBounds = YES;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [self init];
  if (self) {
    self.frame = frame;
    self.cornerRadius = self.frame.size.width/2.0;
  }
  return self;
}

- (void)setLayerType:(QCPRefreshLayerType)layerType
{
  _layerType = layerType;
  switch (layerType) {
    case QCPRefreshLayerRed:
      self.backgroundColor = [UIColor redColor].CGColor;
      break;
    case QCPRefreshLayerYellow:
      self.backgroundColor = [UIColor orangeColor].CGColor;
      break;
    case QCPRefreshLayerGreen:
      self.backgroundColor = [UIColor greenColor].CGColor;
      break;
    default:
      break;
  }
}

- (void)addAnimationToPositionY:(CGFloat)yPosion withKey:(NSString *)key
{
  CABasicAnimation *animation = [CABasicAnimation animation];
  animation.keyPath = @"position.y";
  animation.duration = 2.0;
  animation.toValue = @(yPosion);
  [self addAnimation:animation forKey:key];
}

@end

