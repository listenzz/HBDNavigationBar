//
//  ShadowHiddenViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/3/23.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "ShadowHiddenViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface ShadowHiddenViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

@end

@implementation ShadowHiddenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.switchControl.on = YES;
    self.hbd_barShadowHidden = YES;
}

- (IBAction)onHiddenChanged:(UISwitch *)sender {
    self.hbd_barShadowHidden = sender.on;
    [self hbd_setNeedsUpdateNavigationBarShadowImageAlpha];
}


@end
