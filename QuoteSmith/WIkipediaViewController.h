//
//  WIkipediaViewController.h
//  QuoteSmith
//
//  Created by waffles on 5/12/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WIkipediaViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
- (void) loadAddress : (NSString *) address;
@end
