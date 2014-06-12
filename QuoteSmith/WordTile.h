//
//  WordTile.h
//  QuoteSmith
//
//  Created by waffles on 4/2/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import <UIKit/UIKit.h>

enum TILE_MODES {
    TILE_MODE_GAME,
    TILE_MODE_WIN,
};

@interface WordTile : UIView

- (void) setString : (NSString *) str;
- (NSString *) str;
- (void) executeTween;
- (void) highlightGreen;
- (void) highlightRed;
- (void) addTweenTarget : (CGPoint) target;

@property (nonatomic, assign) int mode;
@property (nonatomic, assign) int line;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) BOOL    customColors;
@property (nonatomic, retain) UIColor *bgColor;
@property (nonatomic, retain) UIColor *fgColor;

@end
