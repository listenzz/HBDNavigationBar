//
//  FSPNavigationController.m
//  HBDNavigationBar_Example
//
//  Created by 李生 on 2019/9/27.
//  Copyright © 2019 listenzz@163.com. All rights reserved.
//

#import "FSPNavigationController.h"
#import "HBDPushAnimation.h"
#import "HBDPopAnimation.h"

@interface FSPNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *hbd_interactiveTransition;

@end

@implementation FSPNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取系统自带滑动手势的target对象
    id target = self.interactivePopGestureRecognizer.delegate;
    // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    // 设置手势代理，拦截手势触发
    pan.delegate = self.interactivePopGestureRecognizer.delegate;
    // 给导航控制器的view添加全屏滑动手势
    [self.view addGestureRecognizer:pan];
    // 禁止使用系统自带的滑动手势
    self.interactivePopGestureRecognizer.enabled = NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
animationControllerForOperation:(UINavigationControllerOperation)operation
             fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
            return [HBDPushAnimation new];
    } else if (operation == UINavigationControllerOperationPop) {
        return [HBDPopAnimation new];
    }
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController  {
    if ([animationController isKindOfClass:[HBDPopAnimation class]]) {
       return self.hbd_interactiveTransition;
    }
    return nil;
}

- (void)handleFullScreenGesture:(UIPanGestureRecognizer *)pan {
    CGFloat process = [pan translationInView:self.view].x / self.view.bounds.size.width;
    process = MIN(1.0,(MAX(0.0, process)));
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"%s UIGestureRecognizerStateBegan", __FUNCTION__);
        self.hbd_interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        //触发pop转场动画
        [self popViewControllerAnimated:YES];
    }else if (pan.state == UIGestureRecognizerStateChanged){
        NSLog(@"%s UIGestureRecognizerStateChanged", __FUNCTION__);
        UIPercentDrivenInteractiveTransition *transition = self.hbd_interactiveTransition;
        [transition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        NSLog(@"%s UIGestureRecognizerStateEnded", __FUNCTION__);
        if (process > 0.33) {
            [ self.hbd_interactiveTransition finishInteractiveTransition];
        }else{
            [ self.hbd_interactiveTransition cancelInteractiveTransition];
        }
        self.hbd_interactiveTransition = nil;
    }
}

@end
