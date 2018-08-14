//
//  DemoViewController.m
//  HBDNavigationBar_Example
//
//  Created by Listen on 2018/4/18.
//  Copyright © 2018年 listenzz@163.com. All rights reserved.
//

#import "DemoViewController.h"
#import <HBDNavigationBar/UIViewController+HBD.h>
#import <HBDNavigationBar/HBDNavigationController.h>
#import "YPGradientDemoViewController.h"

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *shadowHiddenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *barHiddenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *blackStyleSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;
@property (weak, nonatomic) IBOutlet UILabel *alphaComponent;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"%lu", self.navigationController.childViewControllers.count];
    if (self.navigationController.childViewControllers.count <= 2) {
        self.title = @"我";
        // self.hbd_tintColor = UIColor.whiteColor;
    } else {
        self.title = @"收藏";
        self.hbd_tintColor = UIColor.blueColor;
        // self.hbd_barTintColor = UIColor.redColor;
        // self.hbd_barStyle = UIBarStyleBlack;
        // self.hbd_titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.whiteColor };
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.alphaComponent.text = [NSString stringWithFormat:@"%.2f", sender.value];
    self.hbd_barAlpha = sender.value;
    [self hbd_setNeedsUpdateNavigationBarAlpha];
}

- (IBAction)pushToNext:(UIButton *)sender {
    UIViewController *vc = [self createDemoViewController];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)dynamicGradient:(UIButton *)sender {
    UIViewController *vc = [[YPGradientDemoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIViewController *)createDemoViewController {
    DemoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"demo"];
    
    vc.hbd_barShadowHidden = self.shadowHiddenSwitch.isOn;
    vc.hbd_barHidden = self.barHiddenSwitch.isOn;
    vc.hbd_barStyle = self.blackStyleSwitch.isOn ? UIBarStyleBlack : UIBarStyleDefault;
    UIColor *color = @[
                       [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.8],
                       [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.729],
                       [UIColor.redColor colorWithAlphaComponent:0.7],
                       [UIColor.greenColor colorWithAlphaComponent:0.7],
                       [UIColor.blueColor colorWithAlphaComponent:0.8]
                       ][self.colorSegment.selectedSegmentIndex];
    
    vc.hbd_barTintColor = color;
    // vc.hbd_barImage = [DemoViewController imageWithColor:color];
    return vc;
}


+ (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 8.0f, 8.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
