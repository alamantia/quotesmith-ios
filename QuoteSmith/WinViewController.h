//
//  WinViewController.h
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

@class GameViewController;

@interface WinViewController : UIViewController <UIWebViewDelegate> {
    
}
@property (nonatomic, strong) GameViewController *delegate;
@property (nonatomic, strong) NSDictionary *quote;
@property (nonatomic, assign) struct HSV bgHSV;
- (void) displayQuote;
- (void) displayBio:(CGPoint) p;

@end
