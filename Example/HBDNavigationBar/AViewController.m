//
//  AViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/10/24.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//
#import <HBDNavigationBar/UIViewController+HBD.h>
#import <HBDNavigationBar/HBDNavigationController.h>
#import "AViewController.h"
#import "CViewController.h"

@interface AViewController ()

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.hbd_barHidden = YES;
    self.hbd_barAlpha = 0;
    self.view.backgroundColor = [UIColor colorWithRed:((float) arc4random_uniform(256) / 255.0) green:((float) arc4random_uniform(256) / 255.0) blue:((float) arc4random_uniform(256) / 255.0) alpha:1.0];
}

- (void)pushToNext:(UIButton *)button {
    AViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"a"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)presentC:(UIButton *)sender {
    UIViewController *vc = [[CViewController alloc] init];
    HBDNavigationController *nav = [[HBDNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.navigationController.definesPresentationContext = NO;
    [self presentViewController:nav animated:YES completion:^{

    }];
}

@end
