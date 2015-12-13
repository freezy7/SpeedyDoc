//
//  QCPRefreshLoadingView.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/12/11.
//  Copyright © 2015年 R_style Man. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  QCPRefreshLayerRed,
  QCPRefreshLayerYellow,
  QCPRefreshLayerGreen
}QCPRefreshLayerType;

@interface QCPRefreshLoadingView : UIView

- (void)showInView:(UIScrollView *)scrollView;

- (void)rotate;

@end

@interface QCPRefreshLoadingLayer : CALayer

@property (nonatomic, assign) QCPRefreshLayerType layerType;

- (id)initWithFrame:(CGRect)frame;

- (void)addAnimationToPositionY:(CGFloat)yPosion withKey:(NSString *)key;

@end
