//
//  WinViewController.h
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinViewController : UIViewController <UIWebViewDelegate> {
    
}
@property (nonatomic, strong) NSDictionary *quote;
- (void) displayQuote;
@end
