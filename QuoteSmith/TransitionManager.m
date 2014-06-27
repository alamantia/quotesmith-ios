//
//  TransitionManager.m
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "TransitionManager.h"
@implementation TransitionManager
#pragma mark - UIViewControllerAnimatedTransitioning -

//Define the transition duration
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.0;
}

//Define the transition
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //STEP 1
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
    if (self.transitionTo == T_BLOCK_FWD || self.transitionTo == T_BLOCK_PREV) {
        
        UIView *container = [transitionContext containerView];
        [container insertSubview:toVC.view belowSubview:fromVC.view];
        
        toVC.view.center = CGPointMake(-sourceRect.size.width, sourceRect.size.height);
        toVC.view.alpha = 0;
        toVC.view.frame = fromVC.view.frame;
        toVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);

        //1.Settings for the fromVC ............................
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:.8
              initialSpringVelocity:6.0
                            options:UIViewAnimationOptionCurveEaseIn
         
                         animations:^{
                             fromVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                             fromVC.view.alpha = 0;
                             toVC.view.alpha = 1;
                             toVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0);

                             toVC.view.frame = CGRectMake(0, 0, toVC.view.bounds.size.width, toVC.view.bounds.size.height);
                             toVC.view.transform = CGAffineTransformMakeRotation(-0);

                         } completion:^(BOOL finished) {
                             fromVC.view.transform = CGAffineTransformIdentity;
                             [transitionContext completeTransition:YES];
                             
                         }];

        
        return;
    }
    
    
    if (self.transitionTo == T_BLOCK_PREV) {
        
        return;
    }
    
    
    /*
     STEP 2:   Draw different transitions depending on the view to show
     for sake of clarity this code is divided in two different blocks
     */
    
    
    //STEP 2A: From the First View(INITIAL) -> to the Second View(MODAL)
    if(self.transitionTo == MODAL){
        //1.Settings for the fromVC ............................
        CGAffineTransform rotation;
        rotation = CGAffineTransformMakeRotation(M_PI);
        fromVC.view.frame = sourceRect;
        fromVC.view.layer.anchorPoint = CGPointMake(0.5, 0.0);
        fromVC.view.layer.position = CGPointMake(160.0, 0);
        
        //2.Insert the toVC view...........................
        UIView *container = [transitionContext containerView];
        [container insertSubview:toVC.view belowSubview:fromVC.view];
        CGPoint final_toVC_Center = toVC.view.center;
        
        toVC.view.center = CGPointMake(-sourceRect.size.width, sourceRect.size.height);
        toVC.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        //3.Perform the animation...............................
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:.8
              initialSpringVelocity:6.0
                            options:UIViewAnimationOptionCurveEaseIn
         
                         animations:^{
                             
                             //Setup the final parameters of the 2 views
                             //the animation interpolates from the current parameters
                             //to the next values.
                             fromVC.view.transform = rotation;
                             toVC.view.center = final_toVC_Center;
                             toVC.view.transform = CGAffineTransformMakeRotation(0);
                         } completion:^(BOOL finished) {
                             
                             //When the animation is completed call completeTransition
                             [transitionContext completeTransition:YES];
                             
                         }];
    //STEP 2B: From the Second view(MODAL) -> to the First View(INITIAL)
    } else if (self.transitionTo == INITIAL) {
        
        //Settings for the fromVC ............................
        CGAffineTransform rotation;
        rotation = CGAffineTransformMakeRotation(M_PI);
        UIView *container = [transitionContext containerView];
        fromVC.view.frame = sourceRect;
        fromVC.view.layer.anchorPoint = CGPointMake(0.5, 0.0);
        fromVC.view.layer.position = CGPointMake(160.0, 0);
        
        //Insert the toVC view view...........................
        [container insertSubview:toVC.view belowSubview:fromVC.view];
        
        toVC.view.layer.anchorPoint = CGPointMake(0.5, 0.0);
        toVC.view.layer.position = CGPointMake(160.0, 0);
        toVC.view.transform = CGAffineTransformMakeRotation(-M_PI);
        
        //Perform the animation...............................
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:6.0
                            options:UIViewAnimationOptionCurveEaseIn
         
                         animations:^{
                             
                             //Setup the final parameters of the 2 views
                             //the animation interpolates from the current parameters
                             //to the next values.
                             toVC.view.frame = CGRectMake(0, 0, toVC.view.bounds.size.width, toVC.view.bounds.size.height);
                             //fromVC.view.center = CGPointMake(fromVC.view.center.x - 320, fromVC.view.center.y);
                             toVC.view.transform = CGAffineTransformMakeRotation(-0);
                             
                         } completion:^(BOOL finished) {
                             
                             //When the animation is completed call completeTransition
                             [transitionContext completeTransition:YES];
                             
                         }];
    }
    
    
}
@end
