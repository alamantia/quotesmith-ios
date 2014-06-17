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

@interface CircleView () {
    CALayer *objectLayer;
    CABasicAnimation *radiusMaxAnimation;
    CABasicAnimation *radiusMinAnimation;
}
@end

@implementation CircleView

- (void) defineAnimations {
    /*
    radiusMaxAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    radiusMaxAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    radiusMaxAnimation.toValue = [NSNumber numberWithFloat:65.0];
    radiusMaxAnimation.duration = 10.0f;
    [self.layer addAnimation:radiusMaxAnimation forKey:@"radiusMax"];
    
    radiusMinAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    radiusMaxAnimation.fromValue = [NSNumber numberWithFloat:65.0];
    radiusMaxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    radiusMinAnimation.duration = 10.0f;
    
    [self.layer addAnimation:radiusMaxAnimation forKey:@"radiusMin"];
    */
}

- (void) setupLayer
{
    objectLayer = [CALayer layer];
    objectLayer.frame = self.frame;
    objectLayer.cornerRadius = 64;
    objectLayer.backgroundColor = self.bgColor.CGColor;
    [self.layer addSublayer:objectLayer];
}

- (void) performAnimation1
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:20.0];
    objectLayer.cornerRadius = 0;
    [CATransaction setCompletionBlock:^{
        NSLog(@"Animation Finished");
    }];
    [CATransaction commit];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
    }
    return self;
}

// perform a looping layer animation
- (void) animate
{
    [self performAnimation1];
    return;
}

- (void) setBgColor:(UIColor *)bgColor
{
    objectLayer.backgroundColor = bgColor.CGColor;
    _bgColor = bgColor;

}

@end
