//
//  RectButton.m
//  QuoteSmith
//
//  Created by waffles on 6/24/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//
//
//  just a simple button class .. nothing really fancy
//

#import "RectButton.h"

@implementation RectButton

- (void) styleButton
{
    
    return;
}

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *) _title
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
