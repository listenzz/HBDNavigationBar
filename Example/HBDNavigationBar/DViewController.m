//
//  DViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/11/6.
//  Copyright © 2018 listenzz@163.com. All rights reserved.
//

#import "DViewController.h"

@interface DViewController ()

@end

@implementation DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:((float) arc4random_uniform(256) / 255.0) green:((float) arc4random_uniform(256) / 255.0) blue:((float) arc4random_uniform(256) / 255.0) alpha:1.0];
}

- (IBAction)popToRoot:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
