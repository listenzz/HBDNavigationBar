//
//  CViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/10/24.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "CViewController.h"

@interface CViewController ()

@end

@implementation CViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.backgroundColor = [UIColor colorWithRed:((float) arc4random_uniform(256) / 255.0) green:((float) arc4random_uniform(256) / 255.0) blue:((float) arc4random_uniform(256) / 255.0) alpha:1.0];
}

- (IBAction)dismiss:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pop-to-root" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@end
