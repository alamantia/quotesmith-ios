//
//  CircleView.m
//  QuoteSmith
//
//  Created by waffles on 5/19/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

// animated background cirlces

#import <QuartzCore/QuartzCore.h>
#import "CircleView.h"

@implementation CircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.5;
        self.layer.cornerRadius = 65;
    }
    return self;
}

// perform a looping layer animation
- (void) animate
{
    return;
    CGFloat damping = 0.60;
    [UIView animateWithDuration:2.5 delay:0 usingSpringWithDamping: damping  initialSpringVelocity: 1.0 options:UIViewAnimationOptionCurveEaseIn |
     UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
         self.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {

    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
