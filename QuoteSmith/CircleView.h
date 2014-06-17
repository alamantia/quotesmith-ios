//
//  CircleView.h
//  QuoteSmith
//
//  Created by waffles on 5/19/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@interface CircleView : UIView
@property (nonatomic, assign) struct HSV bgHSV;
@property (nonatomic, strong) UIColor *bgColor;
- (void) animate;

@end
