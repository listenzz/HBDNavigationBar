//
//  BViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/10/24.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "BViewController.h"
#import "CViewController.h"
#import <HBDNavigationBar/HBDNavigationController.h>
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface BViewController ()

@end

@implementation BViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hbd_barTintColor = UIColor.redColor;
    self.hbd_barStyle = UIBarStyleBlack;
    self.hbd_tintColor = UIColor.whiteColor;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toRoot) name:@"pop-to-root" object:nil];

    self.view.backgroundColor = [UIColor colorWithRed:((float) arc4random_uniform(256) / 255.0) green:((float) arc4random_uniform(256) / 255.0) blue:((float) arc4random_uniform(256) / 255.0) alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%s", __FUNCTION__);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop-to-root" object:nil];
}

- (void)toRoot {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)present:(UIButton *)sender {
    UIViewController *vc = [[CViewController alloc] init];
    HBDNavigationController *nav = [[HBDNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.navigationController.definesPresentationContext = NO;
    [self presentViewController:nav animated:YES completion:^{

    }];

}

@end
