//
//  AViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/10/24.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "AViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface AViewController ()

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // self.hbd_barHidden = YES;
    if (self.navigationController.childViewControllers.count == 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:(UIBarButtonItemStylePlain) target:self action:@selector(pushToNext:)];
    }
}

- (void)pushToNext:(UIButton *)button {
    AViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"a"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
