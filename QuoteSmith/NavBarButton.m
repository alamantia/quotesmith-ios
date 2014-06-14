//
//  NavBarButton.m
//  QuoteSmith
//
//  Created by waffles on 6/14/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "NavBarButton.h"

@implementation NavBarButton

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets;
/*
    Bottom
    Top
    Left
    Right
*/
    insets = UIEdgeInsetsMake(0, 0, 0, 15.0f);
    return insets;
}

@end
