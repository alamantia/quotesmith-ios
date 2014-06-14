//
//  ExpandingNavigationBar.m
//  QuoteSmith
//
//  Created by waffles on 6/13/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "ExpandingNavigationBar.h"

@interface ExpandingNavigationBar () {
    BOOL expanded;
}
@end

@implementation ExpandingNavigationBar

- (id) init {
    self = [super init];
    return self;
}

- (IBAction)expand:(NSNotification *) notification
{
    
    UIViewController *sender = notification.object;
    
    NSLog(@"Sender is %p %@", sender, [sender class]);
    
    // stop these guys from changing their positions ..
    // that can ruin the effect!
    
    //self.topItem.rightBarButtonItem
    //self.topItem.leftBarButtonItems
    //self.topItem.titleView

    // can we adjust and access the rootView of the navigationBar here?
    
    
    /*
    sender.view.frame = CGRectMake(sender.view.frame.origin.x,
                                 sender.view.frame.origin.y - 100,
                                 sender.view.frame.size.width,
                                 sender.view.frame.size.height);

    */
    
    if (expanded == NO) {
        expanded = YES;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + 100);
        

    } else {
        expanded = NO;
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 100);
        
    }
    

    return;
}

/*
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(320,100);
    return newSize;
}
*/

- (void)layoutSubviews {
    static int n = NO;
    if (n == NO) {
        n = YES;
        expanded = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(expand:)
                                                     name:@"expandNav"
                                                   object:nil];
    }
    [super layoutSubviews];
    //CGRect f = self.frame;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void) updatePosition
{
    
}

@end
