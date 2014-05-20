//
//  GameViewController.m
//  QuoteSmith
//
//  Created by waffles on 4/2/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//


#import "GameViewController.h"
#import "WinViewController.h"
#import "TransitionManager.h"
#import "WordTile.h"
#import "UIColor+Expanded.h"
unsigned int MIN_COST = 90;

@interface GameViewController ()
{
    CGFloat lastScale;
    CGFloat lastRotation;
    
    CGFloat firstX;
    CGFloat firstY;
    
    NSMutableDictionary *quote;
    NSMutableArray      *tileViews;
    NSMutableArray      *fillViews;
    NSMutableString     *animationViews;
    NSTimer *backgroundTimer;
    
    BOOL moving;
    WordTile *movingView;
    UILabel *debugLabel;
    
}
@property (nonatomic, strong) TransitionManager *transitionManager;
@end

static bool won = NO;

// adjust to case y alignment to be stronger.
float node_cost(CGPoint a, CGPoint b)
{
    return sqrtf((powf((b.x - a.x),2)) + (powf((b.y - a.y),2)));
}

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitionManager = [[TransitionManager alloc] init];
    }
    return self;
}

// calculate and print the order of views
- (void) orderViews
{
    return;
}

// we need to prioritize top right .. used in the global search
- (WordTile *) firstTileInList:(NSArray *) tileList
{
    WordTile *r = nil;
    float lowest = 1000000;
    for (WordTile *t in tileList) {
        CGPoint a = CGPointMake(0, 0);
        int c = node_cost(a, CGPointMake(t.frame.origin.x, t.frame.origin.y));
        if (r == nil) {
            r = t;
            lowest = c;
            continue;
        }
        if (c < lowest) {
            if (t.frame.origin.y > r.frame.origin.y)
                continue;
            r = t;
            lowest = c;
        }
    }
    return r;
}

- (WordTile *) nextTileFromPoint : (CGPoint) a withCurrent:(WordTile *)p
{
    WordTile *r = nil;
    unsigned int lowest = 100000;
    for (WordTile *t in fillViews) {
        if (t == p) {
            continue;
        }
        CGPoint b = CGPointMake(t.frame.origin.x, (t.frame.origin.y ));
        unsigned int cost = node_cost(a, b);
        float y_diff = b.y - p.frame.origin.y;
        NSLog(@"next line %@ to %@ - %i with slope %f -- ydiff %f", p.str, t.str, cost, (a.y - b.y) / (a.x - b.x), y_diff);
        if (y_diff >= MIN_COST)
            continue;
        if (r == nil) {
            r = t;
            lowest = cost;
            continue;
        }
        if (cost < lowest) {
            r = t;
            lowest = cost;
        }
    }
    
    CGPoint b = CGPointMake(r.frame.origin.x, r.frame.origin.y );
    float y_diff = b.y - p.frame.origin.y;
    NSLog(@"b - found %@ cost %i", r.str, lowest);
    NSLog(@"ydiff %@ pre %f", r.str, y_diff);

    if (fabs(y_diff) >= MIN_COST) {
        return nil;
    }

    if (lowest >= MIN_COST) {
        NSLog(@"%@ y_diff %f", r.str, fabs(y_diff));
        NSLog(@"a - found %@ cost %i", r.str, lowest);
    //    return nil;
    }
    return r;
}

// compute the cost between two tiles
- (int) distanceFromTile:(WordTile *) a toTile:(WordTile *) b
{
    int cost = 1000000;
    CGPoint point_a = CGPointMake(a.frame.origin.x + a.frame.size.width, (a.frame.origin.y ));
    CGPoint point_b = CGPointMake(b.frame.origin.x, (b.frame.origin.y ));
    cost = node_cost(point_a, point_b);
    return cost;
}

- (WordTile *) nextTile : (WordTile *) p
{
    WordTile *r = nil;
    unsigned int lowest = 100000;
    for (WordTile *t in fillViews) {
        if (t == p)
            continue;
        // a should be top right
        CGPoint a = CGPointMake(p.frame.origin.x + p.frame.size.width, (p.frame.origin.y ));
        CGPoint b = CGPointMake(t.frame.origin.x, (t.frame.origin.y ));
        unsigned int cost = node_cost(a, b);
        if (r == nil) {
            r = t;
            lowest = cost;
            NSLog(@"%@ to %@ - %i with slope %f ", p.str, t.str, cost, (a.y - b.y) / (a.x - b.x));
            continue;
        }
        CGPoint c = CGPointMake(r.frame.origin.x, (r.frame.origin.y ));
        float  slope_new = (a.y - b.y) / (a.x - b.x);
        float  slope_old = (a.y - c.y) / (a.x - c.x);
        float  slope_diff = slope_new - slope_old;
        NSLog(@"%@ to %@ - %i with slope %f - slope diff %f", p.str, t.str, cost, (a.y - b.y) / (a.x - b.x), slope_diff);
        if (cost < lowest) {
            r = t;
            lowest = cost;
        }
    }
    CGPoint a = CGPointMake(p.frame.origin.x + p.frame.size.width, (p.frame.origin.y ));
    CGPoint b = CGPointMake(r.frame.origin.x, (r.frame.origin.y ));
    float y_diff = b.y - a.y;
    NSLog(@"%@ ydiff %f", r.str, y_diff);
    if (y_diff <= -40) {
        return nil;
    }
    if (y_diff >= 40.0) {
        NSLog(@"Searching next line after %@", p.str);
        CGPoint x = CGPointMake(0, b.y);
        return [self nextTileFromPoint:x withCurrent:p];
    }
    if (lowest >= MIN_COST) {
        return nil;
    }
    NSLog(@"- found %@ cost %i", r.str, lowest);
    return r;
}

- (void) presentFinshed
{
    return;
}

- (void) animateBackground
{
    return;
}

- (NSMutableArray *) chainFromTile : (WordTile *) firstTile
{
    WordTile *current = firstTile;
    NSMutableArray *chain = [[NSMutableArray alloc] init];
    NSLog(@"Building chain from tile %@", firstTile.str);
    [chain addObject:current];
        for (int i = [tileViews count]; i > 0;i--) {
        WordTile *next = [self nextTile:current];
        if (next == nil) {
            break;
        }
    }
    [chain addObject:current];
    [fillViews removeObject:current];
    return chain;
}

- (float) xCost :  (WordTile *) a :(WordTile *)b {
    float cost = 0.0;
    CGPoint pA = CGPointMake(a.frame.origin.x, (a.frame.origin.y ));
    CGPoint pB = CGPointMake(b.frame.origin.x, (b.frame.origin.y ));
    cost = pB.x - pA.x;
    return cost;
}

- (float) yCost : (WordTile *) a :(WordTile *)b {
    float cost = 0.0;
    CGPoint pA = CGPointMake(a.frame.origin.x + a.frame.size.width, (a.frame.origin.y ));
    CGPoint pB = CGPointMake(b.frame.origin.x, (b.frame.origin.y ));
    cost = pB.y - pA.y;
    return cost;
}

// matches everyblock .. searching for full matches .. will not stop at gaps
- (void) beginLogic3
{
    return;
}

- (void) beginLogic2
{
    NSMutableArray *currentChain  = [[NSMutableArray alloc] init];
    NSMutableArray *matchingTiles = [[NSMutableArray alloc] init];
    NSMutableArray *tileList = [[NSMutableArray alloc] init];
    for (WordTile *t in tileViews) {
        [tileList addObject:t];
    }
    NSMutableArray *orderedList = [[NSMutableArray alloc] init];
    while ([tileList count]) {
        WordTile *p = [self firstTileInList:tileList];
        [tileList removeObject:p];
        [orderedList addObject:p];
    }
    for (WordTile *p in orderedList) {
        NSLog(@"-- * -- ordered %@", p.str);
    }
    // every contine statement marks a chain as being broken
    for (int i = 0; i < [orderedList count]-1; i++) {
        WordTile *current = orderedList[i];
        WordTile *next    = orderedList[i+1];
        int cost = [self distanceFromTile:current toTile:next];
        float yCost = [self yCost:current :next];
        float xCost = [self xCost:current :next];
        NSLog(@"cost %i | ycost %f  - xcost %f Checking -- %@ <----> %@", cost, yCost, xCost, current.str, next.str);
        if (yCost <= -40) {
            if ([currentChain containsObject:movingView]) {
                break;
            }
            [currentChain removeAllObjects];
            continue;
        }
        if (yCost >= 40) {
            NSLog(@"%@ is on the next line? X(%f) Y(%f)", next.str, xCost, yCost);
            // we really need to xCost -- from the first work on the current line
            // otherwise we are technically matching all over the place
            if (yCost >= 80) {
                if ([currentChain containsObject:movingView]) {
                    break;
                }
                [currentChain removeAllObjects];
                continue;
            }
        } else {
            if (cost > 100) {
                if ([currentChain containsObject:movingView]) {
                    break;
                }
                [currentChain removeAllObjects];
                continue;
            }
        }
        NSLog(@"Word match");
        for (int j = 0; j < [quote[@"words"] count]-1 ; j ++) {
            NSString *WordA = [quote[@"words"] objectAtIndex:j];
            NSString *WordB = [quote[@"words"] objectAtIndex:j+1];
            if ([WordA.lowercaseString isEqualToString:current.str.lowercaseString]) {
                if ([WordB.lowercaseString isEqualToString:next.str.lowercaseString]) {
                    NSLog(@"-- Two adjacent pairs detected -- %@ <----> %@", current.str, next.str);
                    if (![currentChain containsObject:current])
                        [currentChain addObject:current];
                    if (![currentChain containsObject:next])
                        [currentChain addObject:next];
                    if (![matchingTiles containsObject:current])
                        [matchingTiles addObject:current];
                    if (![matchingTiles containsObject:next])
                        [matchingTiles addObject:next];
                }
            }
        }
    }
    NSLog(@"Checking for moving view %@", movingView.str);
    if ([currentChain containsObject:movingView]) {
        for (WordTile *t in currentChain) {
            [t highlightGreen];
        }
    }
    for (WordTile *t in matchingTiles) {
        //[t highlightGreen];
    }
}


// checks for the end condition
- (void) beginLogic
{
    NSMutableArray *ordered = [[NSMutableArray alloc] init];
    WordTile *current = nil;
    WordTile *first = [self firstTileInList:tileViews];
    debugLabel.text = first.str;
    current = first;
    fillViews = nil;
    fillViews = [[NSMutableArray alloc] init];
    for (WordTile *t in tileViews) {
        [fillViews addObject:t];
    }
    [fillViews removeObject:current];
    [ordered addObject:current];
    for (int i = [tileViews count]; i > 0;i--) {
        WordTile *next = [self nextTile:current];
        if (next == nil) {
            break;
        }
        if ([self yCost:current :next] >= 80) {
            break;
        }
        NSString *s = [NSString stringWithFormat:@"%@ %@ ", debugLabel.text, next.str];
        debugLabel.text = s;
        current = next;
        [ordered addObject:current];
        [fillViews removeObject:current];
    }
    if ([ordered count] <= 0)
        return;
    bool matched = YES;
    
    for (WordTile *t in ordered) {
        NSLog(@"Ordered %@", t.str);
    }
    if ([ordered count] < [quote[@"words"] count]) {
        return;
    }
    for (int i = 0; i < [quote[@"words"] count]; i++) {
        NSString *word = [quote[@"words"] objectAtIndex:i];
        if (i >= [ordered count])
            return;
        WordTile *t = ordered[i];
        if (![[word lowercaseString] isEqualToString:[t.str lowercaseString]]) {
            matched = NO;
        }
        if (matched == YES) {
            NSLog(@"******* MATCHED ******");
            if (!won) {
                won = YES;
                [self performWin];
            }
        }
    }
    return;
}

- (void)setTranslation:(CGPoint)translation inView:(UIView *)view
{

}

- (void)pan:(UIPanGestureRecognizer *)gesture
{

}

- (void) move:(UIPanGestureRecognizer *) gesture
{
    if (moving == YES) {
        if (gesture.view != movingView)
            return;
    }
    [self.view bringSubviewToFront:gesture.view];
    UIView *t = gesture.view;
    CGPoint location = [gesture translationInView:self.view];
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        moving = YES;
        movingView = gesture.view;
        firstX = t.frame.origin.x;
        firstY = t.frame.origin.y;
    } else if ([gesture state] == UIGestureRecognizerStateChanged) {
        CGRect r = t.frame;
        NSLog(@"Moved %f %f", location.x, location.y);
        r.origin.x = firstX + location.x;
        r.origin.y = firstY + location.y;
        t.frame = r;
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        moving = NO;
        [self beginLogic2];
        [self beginLogic];
    }
}

- (void) backgroundTimerTick : (id) sender {
    
}

- (NSDictionary *) grabQuote {
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    d[@"quote"] = @"Silence is a source of great strength.";
    d[@"author"] = @"Lao Tzu";
    d[@"quote_location"]    = @"";
    d[@"author_source"]     = @"";
    d[@"author_url"]        = @"";
    NSArray *words = [d[@"quote"] componentsSeparatedByString:@" "];
    d[@"words"] = [words copy];
    quote = [d copy];
    return d;
}

- (void) setupBoard
{
    [backgroundTimer invalidate];
    backgroundTimer = nil;
    backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(backgroundTimerTick:)
                                           userInfo:nil
                                           repeats:YES];
    [self grabQuote];
    tileViews = [[NSMutableArray alloc] init];
    for (NSString *s in quote[@"words"]) {
        WordTile *tile = [[WordTile alloc] initWithFrame:
                          CGRectMake(
                                                                    300,100,
                                                                    100,100)];
        tile.mode = TILE_MODE_GAME;
        [self.view addSubview:tile];
        CGRect fr = tile.frame;
        fr.origin.x = (int)floor(rand() % (int)(self.view.bounds.size.width  - 60));
        fr.origin.y = (int)floor(rand() % (int)(self.view.bounds.size.height - 60));
        tile.frame = fr;
        [tile setString:s];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        [tile addGestureRecognizer:panRecognizer];
        [tileViews addObject:tile];
    }
    
    WinViewController *win = [[WinViewController alloc] init];
    win.transitioningDelegate = self;
    win.quote = quote;
    
    win.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:win animated:YES completion:^{
        [win displayQuote];
    }];
    return;
}

- (void) setup
{
    won = NO;
    UIImage *bg = [UIImage imageNamed:@"tweed"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    self.view.backgroundColor = [UIColor colorWithHexString:@"e9ecf1"];
    [self.view setOpaque:NO];
    [[self.view layer] setOpaque:NO];
    [self setupBoard];
}
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    moving = NO;
    [self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) animation2
{
    
}

- (void) clearBoard
{
    for (WordTile *t in tileViews) {
        [t removeFromSuperview];
    }
    [fillViews removeAllObjects];
    [tileViews removeAllObjects];
    [self setupBoard];
    won = NO;
    
    WinViewController *win = [[WinViewController alloc] init];
    win.transitioningDelegate = self;
    win.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:win animated:YES completion:^{
    }];
    return;
}

- (void) performWin
{
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         for (WordTile *t in tileViews) {
                             t.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self clearBoard];
                     }];
    
}

- (void) hint
{
    return;
}

// load a quote from the database
- (void) loadQuote
{
    return;
}

/*
 
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/* UIViewControllerTransitioningDelegate */

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source{
    self.transitionManager.transitionTo = T_BLOCK_FWD;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionManager.transitionTo = T_BLOCK_PREV;
    return self.transitionManager;
}


@end
