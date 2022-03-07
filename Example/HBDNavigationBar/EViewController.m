//
//  EViewController.m
//  HBDNavigationBar_Example
//
//  Created by 李生 on 2019/11/27.
//  Copyright © 2019 listenzz@163.com. All rights reserved.
//

#import "EViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface EViewController ()

@end

@implementation EViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.hbd_barTintColor = UIColor.redColor;
    self.hbd_barStyle = UIBarStyleBlack;
    self.hbd_tintColor = UIColor.whiteColor;

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
