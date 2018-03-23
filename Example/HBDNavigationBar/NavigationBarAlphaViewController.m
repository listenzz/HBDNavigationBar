//
//  NavigationAlphaViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/3/23.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "NavigationBarAlphaViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface NavigationBarAlphaViewController ()

@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation NavigationBarAlphaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.slider.value = 0.5;
    self.hbd_barAlpha = 0.5;
}

- (IBAction)onAlphaChanged:(UISlider *)sender {
    self.hbd_barAlpha = sender.value;
    [self hbd_setNeedsUpdateNavigationBarAlpha];
}

@end
