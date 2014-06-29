//
//  GameViewController.m
//  QuoteSmith
//
//  Created by waffles on 4/2/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "GameViewController.h"
#import "WinViewController.h"
#import "TransitionManager.h"
#import "WordTile.h"
#import "UIColor+Expanded.h"
#import "UIColor+HSV.h"
#import "AppContext.h"
#import "NavBarButton.h"
#import "PlasmaBackgrounds.h"
#import "ExpandingNavigationBar.h"

#define ARC4RANDOM_MAX      0x100000000

#define OPTIONS_HEIGHT      44.0

static float hsvStep = (1.0/360.0);
#import "Quotes.h"

unsigned int MIN_COST = 90;

@interface GameViewController ()
{
    Quotes  *quotes;
    PlasmaBackgrounds   *plasmaVc;
    
    BOOL showingOptions;
    CGFloat lastScale;
    CGFloat lastRotation;
    
    CGFloat firstX;
    CGFloat firstY;
    
    NSMutableArray      *particles;
    NSMutableDictionary *quote;
    NSMutableArray      *tileViews;
    NSMutableArray      *fillViews;
    NSMutableString     *animationViews;
    NSTimer *backgroundTimer;
    
    BOOL moving;
    WordTile *movingView;
    UILabel *debugLabel;
    
    UIColor *fgColor;
    UIColor *bgColor;
    
    struct HSV bgHSV;
    UIScrollView *sv;
    
    // some misplaced stuff for the optionsView
    UIView *optionsView;
    UIToolbar *optionsToolbar;
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

- (void) setupOptionsView
{
    // the same color setting the the learn more wikipedia button (for now)
    optionsView.backgroundColor = [UIColor  acolorWithHue:bgHSV.H saturation:bgHSV.S value:bgHSV.V-0.1 alpha:1.0];
    optionsToolbar.translucent = YES;
    optionsToolbar.barTintColor = [UIColor  acolorWithHue:bgHSV.H saturation:bgHSV.S value:bgHSV.V-0.1 alpha:1.0];
    
    optionsToolbar.barTintColor = [UIColor colorWithHexString:@"eeeeee"];

    optionsToolbar.tintColor = [UIColor blackColor];
    return;
}

- (float)randomFloat:(float)min maxNumber:(float)max
{
    float range = max - min;
    float val = ((float)arc4random() / ARC4RANDOM_MAX) * range + min;
    int val1 = val * 10;
    float val2= (float)val1 / 10.0f;
    return val2;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        quotes = [[Quotes alloc] init];
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
            //NSLog(@"%@ to %@ - %i with slope %f ", p.str, t.str, cost, (a.y - b.y) / (a.x - b.x));
            continue;
        }
        CGPoint c = CGPointMake(r.frame.origin.x, (r.frame.origin.y ));
        float  slope_new = (a.y - b.y) / (a.x - b.x);
        float  slope_old = (a.y - c.y) / (a.x - c.x);
        float  slope_diff = slope_new - slope_old;
        //NSLog(@"%@ to %@ - %i with slope %f - slope diff %f", p.str, t.str, cost, (a.y - b.y) / (a.x - b.x), slope_diff);
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
            //[t highlightGreen];
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
        
        
    }
    
    if (matched == YES) {
        NSLog(@"******* MATCHED ******");
        if (!won) {
            won = YES;
            [self performWin];
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

- (void) swipe:(UISwipeGestureRecognizer *) gesture
{
    if (showingOptions == NO) {
        [UIView animateWithDuration:0.15 animations:^{
            CGRect fr = sv.frame;
            fr.origin.y += OPTIONS_HEIGHT;
            sv.frame = fr;
            sv.userInteractionEnabled = YES;
            showingOptions = YES;
        } completion:^(BOOL finished) {
        }];
    }
}


- (void) tap:(UITapGestureRecognizer *) gesture
{
    [self hideOptions];
}

- (void) move:(UIPanGestureRecognizer *) gesture
{
    [self hideOptions];
    if (moving == YES) {
        if (gesture.view != movingView)
            return;
    }
    [sv bringSubviewToFront:gesture.view];
    UIView *t = gesture.view;
    CGPoint location = [gesture translationInView:sv];
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        moving = YES;
        movingView = (WordTile *)gesture.view;
        firstX = t.frame.origin.x;
        firstY = t.frame.origin.y;
    } else if ([gesture state] == UIGestureRecognizerStateChanged) {
        CGRect r = t.frame;
        NSLog(@"Moved %f %f", location.x, location.y);
        
        float targetX = firstX + location.x;
        float targetY = firstY + location.y;
        float newX = firstX    + location.x;
        float newY = firstY    + location.y;

        if (newX + t.frame.size.width >= self.view.frame.size.width) {
            targetX = self.view.frame.size.width - t.frame.size.width;
        } else if (newX <= 0) {
            targetX = 0;
        }

        if (newY + t.frame.size.height >= self.view.frame.size.height) {
            targetY = self.view.frame.size.height - t.frame.size.height;
        } else if (newY <= 0) {
            targetY = 0;
        }
        
        r.origin.x = targetX;
        r.origin.y = targetY;
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
    
    quote = [[quotes randomQuote] copy];
    return quote;
}


- (void) generateColors
{
    NSLog(@"Trying to update with new colors");
    
    float St = [self randomFloat:10 maxNumber:12];
    float Vt = [self randomFloat:98 maxNumber:100];
        
    float H = [self randomFloat:0 maxNumber:360];
    float S = St/100.0;
    float V = Vt/100.0;
        
    NSLog(@"H %f S %f V %f", H, S, V);
    
    bgHSV.H = H;
    bgHSV.S = S;
    bgHSV.V = V;

    bgColor = [UIColor acolorWithHue:H saturation:S value:V alpha:1.0];
    
    //S += 0.5;
    //V += 0.5;
    
    // almost black but with a high contrast hue as a base
    
    S = 8.0/100.0;
    V = 10.0/100.0;
  
    H += 180;
    if (H > 360.0) {
        H = H - 360;
    }
    
    fgColor = [UIColor acolorWithHue:H saturation:S value:V alpha:1.0];
    sv.backgroundColor = bgColor;
    self.view.backgroundColor = bgColor;
    self.navigationController.navigationBar.barTintColor = bgColor;
    self.navigationController.navigationBar.tintColor = fgColor;
    self.navigationController.topViewController.title = @"Quote Smith";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"ffffff"];

    [AppContext sharedContext].fgColor = fgColor;
    [AppContext sharedContext].bgColor = bgColor;
}

- (void) setupBoard
{
    [self generateColors];
    [self setupOptionsView];

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
        tile.customColors = YES;
        tile.fgColor = [[AppContext sharedContext] fgColor];
        tile.bgColor = [[AppContext sharedContext] bgColor];
        
        tile.mode = TILE_MODE_GAME;
        [sv addSubview:tile];
        CGRect fr = tile.frame;
        
        
        // Tweek these so quotes fall in the proper position!tile

        
        [tile setString:s];
        
        fr.origin.x = (int)floor(rand() % (int)(self.view.bounds.size.width  - MAX(tile.frame.size.width, 140)));
        fr.origin.y = (int)floor(rand() % (int)(self.view.bounds.size.height - MAX(tile.frame.size.height,120)));
        tile.frame = fr;

        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        [tile addGestureRecognizer:panRecognizer];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
        [sv addGestureRecognizer:recognizer];
        [tileViews addObject:tile];
    }
    return;
}

- (IBAction) hint : (id)sender
{
    NSArray *_quotes = quote[@"words"];
    int r =   (rand() % [_quotes count]) - 1;
    if (r <= 0) {
        r = 0;
    }
    for (WordTile *t in tileViews) {
        if ([t.str isEqualToString:_quotes[r]]) {
            [t highlightGreen];
        }
        if ([t.str isEqualToString:_quotes[r+1]]) {
            [t highlightGreen];
        }
    }
    // perform the hint logic here
    
    /*
     NSLog(@"Checking for moving view %@", movingView.str);
     if ([currentChain containsObject:movingView]) {
     for (WordTile *t in currentChain) {
     [t highlightGreen];
     }
     }
    */
    
    return;
}

- (IBAction) skip : (id)sender
{
    [self clearBoard];
    return;
}
- (void) viewDidDisappear:(BOOL)animated
{

}

- (void) hideOptions
{
    if (showingOptions == YES) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect fr = sv.frame;
            fr.origin.y -= OPTIONS_HEIGHT;
            sv.frame = fr;
            sv.userInteractionEnabled = YES;
            showingOptions = NO;
        } completion:^(BOOL finished) {
            
        }];
    }
}
- (IBAction) expand: (NSNotification *)notification
{
    NSLog(@"Sending");
    [UIView animateWithDuration:0.25 animations:^{
        if (showingOptions == NO) {
            CGRect fr = sv.frame;
            fr.origin.y += OPTIONS_HEIGHT;
            sv.frame = fr;
            sv.userInteractionEnabled = YES;
            showingOptions = YES;
        } else {
            CGRect fr = sv.frame;
            fr.origin.y -= OPTIONS_HEIGHT;
            sv.frame = fr;
            sv.userInteractionEnabled = YES;
            showingOptions = NO;
        }
    } completion:^(BOOL finished) {
        
    }];
    return;
}

- (void) setup
{
    NavBarButton *settingsView = [[NavBarButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [settingsView addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"icon_40820"] forState:UIControlStateNormal];
    
    UIBarButtonItem *expandButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    [[self navigationItem] setRightBarButtonItems:@[expandButton]];
    won = NO;
    UIImage *bg = [UIImage imageNamed:@"tweed"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    self.view.backgroundColor = [UIColor colorWithHexString:@"e9ecf1"];
    [self.view setOpaque:NO];
    [[self.view layer] setOpaque:NO];
    [self setupBoard];
}

- (IBAction) exit : (id) sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void) populateOptionsView {
    UIBarButtonItem *flexibleSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"SKIP" style:UIBarButtonItemStylePlain target:self action:@selector(skip:)];
    UIBarButtonItem *hintButton = [[UIBarButtonItem alloc] initWithTitle:@"HINT" style:UIBarButtonItemStylePlain target:self action:@selector(hint:)];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"MENU" style:UIBarButtonItemStylePlain target:self action:@selector(exit:)];
    optionsToolbar = [[UIToolbar alloc] initWithFrame:optionsView.frame];
    [optionsToolbar setItems:@[menuButton, flexibleSpace, hintButton, skipButton] animated:YES];
    [optionsView addSubview:optionsToolbar];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    optionsView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, OPTIONS_HEIGHT)];
    [self.view addSubview:optionsView];
    [self populateOptionsView];
    
    sv = [[UIScrollView alloc] initWithFrame:self.view.frame];
    sv.backgroundColor = [UIColor clearColor];
    sv.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    plasmaVc = [[PlasmaBackgrounds alloc] init];
    plasmaVc.view.frame = self.view.frame;
    [sv addSubview:plasmaVc.view];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addSubview:sv];
    [sv addGestureRecognizer:tapGestureRecognizer];
    [Quotes loadIndex];
    [quotes randomQuote];
    self.navigationController.navigationBar.translucent = NO;
    moving = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) animation2
{
    
}

- (void) viewWillAppear:(BOOL)animated
{
    showingOptions = NO;
    CGRect fr = self.navigationController.navigationBar.frame;
    fr.size.height = 700;
    self.navigationController.navigationBar.frame = fr;
}

extern int  current_quote;
- (void) displayWin {
    current_quote++;
    WinViewController *win = [[WinViewController alloc] init];
    win.view.backgroundColor = [[AppContext sharedContext] bgColor];
    win.view.backgroundColor = [UIColor whiteColor];
    
    win.bgHSV = bgHSV;
    win.delegate = self;
    win.quote = quote;
    win.modalPresentationStyle = UIModalPresentationCustom;
    
    UINavigationController *n = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:nil];
    [n pushViewController:win animated:NO];
    
    n.transitioningDelegate = self;
    n.modalPresentationStyle = UIModalPresentationCustom;
    
    [self hideOptions];
    [self presentViewController:n animated:YES completion:^{
        [win displayQuote];
    }];
}
- (void) clearBoard
{
    for (WordTile *t in tileViews) {
        [t removeFromSuperview];
    }
    [fillViews removeAllObjects];
    [tileViews removeAllObjects];
    [self displayWin];
    won = NO;
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
