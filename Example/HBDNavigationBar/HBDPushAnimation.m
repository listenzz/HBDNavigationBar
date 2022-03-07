//
//  HBDPushAnimation.m
//  HBDNavigationBar_Example
//
//  Created by 李生 on 2019/9/28.
//  Copyright © 2019 listenzz@163.com. All rights reserved.
//

#import "HBDPushAnimation.h"

@implementation HBDPushAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.frame = transitionContext.containerView.bounds;
    [transitionContext.containerView addSubview:toView];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];

    toView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, transitionContext.containerView.bounds.size.width, 0);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //fromView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -transitionContext.containerView.bounds.size.width, 0);
        fromView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.93, 0.93);
        toView.transform = CGAffineTransformIdentity;
    }                completion:^(BOOL finished) {
        fromView.transform = CGAffineTransformIdentity;
        toView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
