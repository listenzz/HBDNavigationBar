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
}

- (IBAction)dismiss:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pop-to-root" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
