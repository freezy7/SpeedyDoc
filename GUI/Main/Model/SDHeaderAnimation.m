//
//  SDHeaderAnimation.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/6/27.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "SDHeaderAnimation.h"
#import "SDHeaderAnimatedDelegate.h"
@implementation SDHeaderAnimation

-(id) init
{
    self = [super init];
    if (self) {
        _transitionMode = TransitionModePresent;
        _transitionInteracted = false;
        _headerFormFrame = CGRectZero;
        _headerToFrame = CGRectZero;
    }
    return self;
}

-(void) setDestinationViewController:(UIViewController *)destinationViewController
{
    _destinationViewController = destinationViewController;
    // 滑动返回取消
//    _enterPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnstagePan:)];
//    [_destinationViewController.view addGestureRecognizer:_enterPanGesture];
}

-(CGFloat)completionSpeed
{
    return 1-self.percentComplete;
}

-(void) handleOnstagePan:(UIPanGestureRecognizer *)pan
{
    CGPoint translation = [pan translationInView:pan.view];
    CGFloat d = translation.y/CGRectGetHeight(pan.view.bounds)*1.5;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _transitionInteracted = YES;
        [self.destinationViewController dismissViewControllerAnimated:YES completion:nil];
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self updateInteractiveTransition:d];
        _shouldComplete = (d > 0.5);
        
    }else{// Ended, Cancelled, Failde
        _transitionInteracted = NO;
        if (!_shouldComplete || pan.state == UIGestureRecognizerStateCancelled) {
            [self cancelInteractiveTransition];
        } else {
            [self finishInteractiveTransition];
        }
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.65;
}

-(void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView* container = [transitionContext containerView];
    
    // 兼容 iOS7 UITransitionContextFromViewKey 暂时不用
//    UIView* fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//    UIView* toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIViewController<SDHeaderAnimationDelegate>* fromController;
    UIViewController<SDHeaderAnimationDelegate>* toController;
    
    if ([[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] isKindOfClass:[UINavigationController class]]) {
        fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].childViewControllers[0];
    } else {
        fromController = (UIViewController<SDHeaderAnimationDelegate> *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    
    if ([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[UINavigationController class]]) {
        toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].childViewControllers[0];
    } else {
        toController = (UIViewController<SDHeaderAnimationDelegate> *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    
    
    UIView* fromView = fromController.view;
    UIView* toView = toController.view;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [fromView setNeedsDisplay];
    [fromView layoutIfNeeded];
    [toView setNeedsDisplay];
    [toView layoutIfNeeded];
    
    CGFloat alpha = 0.1;
    CGAffineTransform offScreenBottom = CGAffineTransformMakeTranslation(0, container.frame.size.height);
    
    // Prepare header
    UIView* headerTo = [toController headerView];
    UIView* headerFrom = [fromController headerView];
    
    [headerTo layoutIfNeeded];
    [headerFrom layoutIfNeeded];
    
    
    if (_transitionMode == TransitionModePresent) {
        _headerToFrame = [headerTo.superview convertRect:headerTo.frame toView:nil];
        _headerFormFrame = [headerFrom.superview convertRect:headerFrom.frame toView:nil];
    }

    headerFrom.hidden = YES;
    headerTo.hidden = YES;
    
    UIView* headerIntermediate = [fromController headerCopy:nil];
    headerIntermediate.frame = _transitionMode == TransitionModePresent ? _headerFormFrame: _headerToFrame;
        
    if (_transitionMode == TransitionModePresent) {
        toView.transform = offScreenBottom;
        //加载的是navgationController 的view
        [container addSubview:[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view];
        [container addSubview:toView];
        [container addSubview:headerIntermediate];
    } else {
        toView.alpha = alpha;
        [container addSubview:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view];
        [container addSubview:fromView];
        [container addSubview:headerIntermediate];
    }
    
    // Perform animation
    [UIView animateWithDuration:duration animations:^{
        
        if (_transitionMode == TransitionModePresent) {
            fromView.alpha = alpha;
            toView.transform = CGAffineTransformIdentity;
            headerIntermediate.frame = _headerToFrame;
        } else {
            fromView.transform = offScreenBottom;
            toView.alpha = 1.0;
            headerIntermediate.frame = _headerFormFrame;
        }
    } completion:^(BOOL finished) {
        
        [headerIntermediate removeFromSuperview];
        headerTo.hidden = NO;
        headerFrom.hidden = NO;
        
        [transitionContext completeTransition:YES];
    
    }];
    
}

#pragma mark - UIViewControllerInteractiveTransitioning

-(void) startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [super startInteractiveTransition:transitionContext];
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    _transitionMode = TransitionModePresent;
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed
{
    _transitionMode = TransitionModeDismiss;
    return self;
}

-(id<UIViewControllerInteractiveTransitioning>) interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.transitionInteracted ? self : nil;
}


@end
