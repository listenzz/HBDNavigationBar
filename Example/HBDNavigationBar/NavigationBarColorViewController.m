//
//  ColorViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/3/23.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "NavigationBarColorViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface NavigationBarColorViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic, copy) NSArray *colors;
@end

@implementation NavigationBarColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.colors = @[[UIColor.redColor colorWithAlphaComponent:0.8], [UIColor.greenColor colorWithAlphaComponent:0.8], [UIColor.blueColor colorWithAlphaComponent:0.8] ];
    self.segment.selectedSegmentIndex = 0;
    self.hbd_barTintColor = self.colors[0];
}

- (IBAction)onColorSelected:(UISegmentedControl *)sender {
    self.hbd_barTintColor = self.colors[sender.selectedSegmentIndex];
    [self hbd_setNeedsUpdateNavigationBarColor];
}

@end
