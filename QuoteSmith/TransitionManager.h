//
//  TransitionManager.h
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TransitionStep){
    INITIAL = 0,
    MODAL,
    T_BLOCK_FWD,
    T_BLOCK_PREV,
};

@interface TransitionManager : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) TransitionStep transitionTo;

@end
