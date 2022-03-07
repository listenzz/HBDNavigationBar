//
//  TableViewController.m
//  HBDNavigationBar_Example
//
//  Created by 李生 on 2019/11/23.
//  Copyright © 2019 listenzz@163.com. All rights reserved.
//

#import "TableViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hbd_barStyle = UIBarStyleBlack;
    self.hbd_barTintColor = UIColor.redColor;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

@end
