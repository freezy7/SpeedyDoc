//
//  SDHeaderAnimation.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/6/27.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TransitionMode){
    TransitionModePresent,
    TransitionModeDismiss
};

@interface SDHeaderAnimation : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning,UIViewControllerInteractiveTransitioning,UIViewControllerTransitioningDelegate>
{
    CGRect _headerFormFrame;
    CGRect _headerToFrame;
    
    UIPanGestureRecognizer* _enterPanGesture;
}

@property (assign,nonatomic) TransitionMode transitionMode;
@property (assign,nonatomic) BOOL transitionInteracted;

@property (strong,nonatomic) UIViewController* destinationViewController;

@end
