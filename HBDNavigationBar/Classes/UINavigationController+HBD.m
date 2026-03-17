//
//  UINavigationController+HBD.m
//  HBDNavigationBar
//
//  Created by Codex on 2026/3/18.
//

#import "UINavigationController+HBD.h"

#import "UIViewController+HBD.h"

@implementation UINavigationController (HBD)

- (void)redirectToViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self redirectToViewController:controller target:self.topViewController animated:animated];
}

- (void)redirectToViewController:(UIViewController *)controller target:(UIViewController *)target animated:(BOOL)animated {
    NSMutableArray<UIViewController *> *children = [self.childViewControllers mutableCopy];
    NSUInteger index = [children indexOfObject:target];
    if (index == NSNotFound) {
        index = [children indexOfObject:self.topViewController];
    }

    if (index == NSNotFound) {
        return;
    }

    NSUInteger count = children.count;
    [children removeObjectsInRange:NSMakeRange(index, count - index)];
    [children addObject:controller];
    if (children.count > 1) {
        controller.hidesBottomBarWhenPushed = self.hidesBottomBarWhenPushed;
    }
    [self setViewControllers:children animated:animated];
}

@end
