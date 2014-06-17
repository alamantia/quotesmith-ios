//
//  AppContext.m
//  QuoteSmith
//
//  Created by waffles on 5/20/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "AppContext.h"

@implementation AppContext

+ (id)sharedContext {
    static AppContext *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (UIFont *) fontForType : (int) fontType
{
    // adjust the font sizes as required for the devices in question
    if (fontType == FONT_TYPE_TILE) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            return [UIFont fontWithName:@"Futura-Medium" size:28.0];
        } else {
            return [UIFont fontWithName:@"Futura-Medium" size:40.0];
        }
    }
    
    if (fontType == FONT_TYPE_WIN_TILE) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            return [UIFont fontWithName:@"Futura-CondensedExtraBold" size:28.0];
        } else {
            return [UIFont fontWithName:@"Futura-CondensedExtraBold" size:40.0];
        }
    }
    
    if (fontType == FONT_TYPE_AUTHOR) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            return [UIFont fontWithName:@"Futura-MediumItalic" size:16.0];
        } else {
            return [UIFont fontWithName:@"Futura-MediumItalic" size:24.0];
        }
    }
    if (fontType == FONT_TYPE_BIO) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            return [UIFont fontWithName:@"Futura-Medium" size:16.0];
        } else {
            return [UIFont fontWithName:@"Futura-Medium" size:24.0];
        }
    }
    
    if (fontType == FONT_TYPE_WIN_BUTTON) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            return [UIFont fontWithName:@"Futura-Medium" size:26.0];
        } else {
            return [UIFont fontWithName:@"Futura-Medium" size:32.0];
        }
    }
    
    return nil;
}

- (float) fontSizeForType:(int)fontType
{
    return 40.0;
}

@end
