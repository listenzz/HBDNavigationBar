//
//  YPNavigationTitleLabel.m
//  YPNavigationBarTransition-Example
//
//  Created by Li Guoyin on 2017/12/26.
//  Copyright © 2017年 yiplee. All rights reserved.
//

#import "YPNavigationTitleLabel.h"

@implementation YPNavigationTitleLabel

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
    }
    
    return self;
}

@end
