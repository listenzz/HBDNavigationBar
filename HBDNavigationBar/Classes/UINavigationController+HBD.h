//
//  UINavigationController+HBD.h
//  HBDNavigationBar
//
//  Created by Codex on 2026/3/18.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (HBD)

- (void)redirectToViewController:(UIViewController *)controller animated:(BOOL)animated;

- (void)redirectToViewController:(UIViewController *)controller target:(UIViewController *)target animated:(BOOL)animated;

@end
