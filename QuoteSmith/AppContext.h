//
//  AppContext.h
//  QuoteSmith
//
//  Created by waffles on 5/20/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FONT_TYPES {
    FONT_TYPE_WIN_TILE,
    FONT_TYPE_TILE,
    FONT_TYPE_BIO,
    FONT_TYPE_BUTTON,
    FONT_TYPE_AUTHOR,
    FONT_TYPE_WIN_BUTTON,
};

@interface AppContext : NSObject

@property (nonatomic, retain) UIFont *labelFont;


- (float) fontSizeForType : (int) fontType;
- (UIFont *) fontForType : (int) fontType;

@property (nonatomic, retain) UIColor *fgColor;
@property (nonatomic, retain) UIColor *bgColor;

+ (AppContext *) sharedContext;

@end
