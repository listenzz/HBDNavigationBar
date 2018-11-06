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
}

- (IBAction)popToRoot:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
