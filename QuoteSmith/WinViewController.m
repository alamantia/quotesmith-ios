    //
//  WinViewController.m
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.

#import <Social/Social.h>

#import "WinViewController.h"
#import "UIColor+Expanded.h"
#import "WIkipediaViewController.h"
#import "GameViewController.h"
#import "AppContext.h"
#import "UIColor+HSV.h"
#import "WordTile.h"
#import "NavBarButton.h"
#import "ExpandingNavigationBar.h"


#define MY_INTERSTITIAL_UNIT_ID @"ca-app-pub-8721364252541931/3727404808"

@interface WinViewController () {
    
    GADInterstitial *interstitial_;
    BOOL historyMode;
    UIButton *buttonNext;
    UIButton *buttonWikipedia;
    
    WordTile *authorTile;
    UILabel *authorView;
    NSMutableArray *tileArray;
    NSMutableArray *targetsArray;
    NSMutableArray *pendingTiles;
    UILabel *bioLabel;
    int animation_line;
    
    UITextView *quoteInfo;
    UIFont     *quoteFont;
    UIColor    *quoteColor;
    
    UIFont     *bioFont;
    UIColor    *bioColor;
    
    float cHeight;
    float bioY;
    float cY;
    float cX;
    int   line;
    
    UIScrollView *sv;
}

@end

@implementation WinViewController

- (void) viewWillAppear:(BOOL)animated
{
    
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.barTintColor = [AppContext sharedContext].bgColor;
    //self.navigationController.navigationBar.tintColor = [AppContext sharedContext].fgColor;
    self.navigationController.topViewController.title = @"Quote Smith";
    
    
    if (historyMode)
    {
        return;
    }
    NavBarButton *settingsView = [[NavBarButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [settingsView addTarget:self action:@selector(finished:) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"icon_26914"] forState:UIControlStateNormal];
    UIBarButtonItem *expandButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    [[self navigationItem] setRightBarButtonItems:@[expandButton]];
}

- (void) historyMode
{
    historyMode = YES;
}

- (WordTile *) startTileWithString : (NSString *) s : (int) x : (int) y
{
    // compute this again here so the size isn't adjusted durring animation (should move to wordtile but w\e)
    CGSize max = CGSizeMake(self.view.bounds.size.width,
                            self.view.bounds.size.height);
    
    CGRect titleLabelRect = [s boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:quoteFont} context:nil];

    WordTile *t = [[WordTile alloc] initWithFrame:CGRectMake(   0 ,0,
                                                                titleLabelRect.size.width,titleLabelRect.size.height)];
    t.mode = TILE_MODE_WIN;
    CGRect fr = t.frame;
    fr.origin.x = x;
    fr.origin.y = -100; // inital x position higher up
    t.frame = fr;
    [t setString:s];
    [sv addSubview:t];
    return t;
}

- (void) displayNext
{
    buttonNext.hidden = NO;
    [UIView animateWithDuration:0.20 animations:^{
        buttonNext.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void) tweet : (id) sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.quote[@"quote"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"You must configure a Twitter account in your device settings before posting."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) facebook : (id) sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:self.quote[@"quote"]];
        [self presentViewController:controller animated:YES completion:Nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"You must configure a Facebook account in your device settings before posting."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) displaySocial : (float) positionY
{
    
    float xOff = self.view.bounds.size.width;
    xOff -= 20;
    xOff -= 40;
    
    NavBarButton *facebookView = [[NavBarButton alloc] initWithFrame:CGRectMake(xOff, positionY, 40, 44)];
    [facebookView addTarget:self action:@selector(facebook:) forControlEvents:UIControlEventTouchUpInside];
    [facebookView setBackgroundImage:[UIImage imageNamed:@"facebook_share"] forState:UIControlStateNormal];
    [sv addSubview:facebookView];

    xOff -= 60;
    
    NavBarButton *twitterView = [[NavBarButton alloc] initWithFrame:CGRectMake(xOff, positionY, 40, 44)];
    [twitterView addTarget:self action:@selector(tweet:) forControlEvents:UIControlEventTouchUpInside];
    [twitterView setBackgroundImage:[UIImage imageNamed:@"twitter_share"] forState:UIControlStateNormal];
    [sv addSubview:twitterView];
    
    facebookView.alpha = 0.0;
    twitterView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         facebookView.alpha = 1.0;
                         twitterView.alpha = 1.0;
                         buttonWikipedia.alpha = 1.0;
                         bioLabel.alpha = 1.0;
                     }];
    return;
}

- (void) displayBio
{
    CGRect authorFrame = authorView.frame;
    bioColor   = [UIColor colorWithHexString:@"17b680"];
    bioFont    = [[AppContext sharedContext] fontForType:FONT_TYPE_BIO];

    NSString *bioString = self.quote[@"author_bio"];
    NSLog(@"Quote String is %@", bioString);
    
    CGSize max = CGSizeMake(self.view.bounds.size.width - 40,
                            self.view.bounds.size.height);
    
    UIView *tView = [[UIView alloc] initWithFrame:authorFrame];
    tView.backgroundColor = [UIColor grayColor];
    //[self.view addSubview:tView];
    
    CGRect labelRect = [bioString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:bioFont} context:nil];
    
    cY = authorFrame.size.height + authorFrame.origin.y;
    cY += 50;
    
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/2) - (labelRect.size.width/2) , cY, labelRect.size.width, labelRect.size.height)];
    bioLabel.font = bioFont;
    
    bioLabel.textColor = bioColor;
    bioLabel.numberOfLines = 0;
    bioLabel.textColor = [[AppContext sharedContext] fgColor];
    bioLabel.text = bioString;
    bioLabel.alpha = 0.0;
    [sv addSubview:bioLabel];
    

    cY += labelRect.size.height;
    cY += 50;
    /// Draw the wikipedia button .. Learn More about X
    
    NSString *wikiString = [NSString stringWithFormat:@"Learn more about %@",
                            [self.quote objectForKey:@"author"]];
    buttonWikipedia = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonWikipedia.frame = CGRectMake((self.view.bounds.size.width/2) - (labelRect.size.width/2), 140, 240, 30);
    buttonWikipedia.titleLabel.numberOfLines = 0;
    buttonWikipedia.alpha = 0.0;
    [buttonWikipedia addTarget:self action:@selector(wikipedia:) forControlEvents:UIControlEventTouchUpInside];
    [buttonWikipedia setTitle:wikiString forState:UIControlStateNormal];
    buttonWikipedia.titleLabel.font = [[AppContext sharedContext] fontForType:FONT_TYPE_WIN_BUTTON];
    buttonWikipedia.titleLabel.textAlignment = NSTextAlignmentCenter;
    CGRect titleLabelRect = [wikiString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:buttonWikipedia.titleLabel.font} context:nil];
    buttonWikipedia.frame = CGRectMake(((self.view.bounds.size.width/2) - (titleLabelRect.size.width/2) - 10 ),
                                       cY,
                                       titleLabelRect.size.width + 20,
                                       titleLabelRect.size.height + 20);
    [buttonWikipedia setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    buttonWikipedia.layer.borderColor = [UIColor blackColor].CGColor;
    buttonWikipedia.layer.borderWidth = 1.0;
    buttonWikipedia.backgroundColor = [UIColor  acolorWithHue:self.bgHSV.H saturation:self.bgHSV.S value:self.bgHSV.V-0.2 alpha:1.0];
    buttonWikipedia.backgroundColor = [UIColor clearColor];
    [sv addSubview:buttonWikipedia];
    sv.contentSize = CGSizeMake(self.view.frame.size.width, cY + titleLabelRect.size.height + 200);
    
    [self displaySocial:cY + titleLabelRect.size.height + 50];
}

// display some author detail
- (void) displayAuthor
{
    UIFont *authorFont = [[AppContext sharedContext] fontForType:FONT_TYPE_AUTHOR];
    
    NSString *s = [NSString stringWithFormat:@"%@",[self.quote objectForKey:@"author"]];
    CGSize max = CGSizeMake(self.view.bounds.size.width - 80,
                            self.view.bounds.size.height);
    
    float padding        = 40;
    float padding_height = 20;
    float t_y_offset = (self.view.bounds.size.height/4) - (cHeight * line);

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
        t_y_offset = 10;
    } else {
        t_y_offset = 80;
    }
    
    CGRect authorFrameRect = [s boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:authorFont} context:nil];
    CGRect authorFrame;
    authorFrame.origin.x = self.view.bounds.size.width - authorFrameRect.size.width - 20;
    authorFrame.origin.y = -100;
    authorFrame.size.width = authorFrameRect.size.width;
    authorFrame.size.height = authorFrameRect.size.height;
    
    authorView = [[UILabel alloc] initWithFrame:authorFrame];
    authorView.textColor = [[AppContext sharedContext] fgColor];
    authorView.font = authorFont;
    authorView.numberOfLines = 0;
    authorView.text = s;
    
    [sv addSubview:authorView];
    bioY = t_y_offset + cY + cHeight + padding_height;
    
    CGFloat damping = 0.60;
    [UIView animateWithDuration:0.20 delay:0 usingSpringWithDamping: damping  initialSpringVelocity: 1.0 options:0 animations:^{
        authorView.frame = CGRectMake(self.view.bounds.size.width - authorFrameRect.size.width - 20,
                             bioY,
                             authorFrameRect.size.width,
                             authorFrameRect.size.height);
        cY = t_y_offset + cY + cHeight + padding_height + authorFrameRect.size.height;
    } completion:^(BOOL finished) {
        if ([pendingTiles count] <= 0) {
            [self displayBio];
            [self displayNext];
            return;
        }
    }];
    [self ad];
}

- (WordTile *) randomPendingTile
{
    WordTile *t = nil;
    if ([pendingTiles count] <= 0) {
        return nil;
    }
    int i = rand() % [pendingTiles count];
    t = [pendingTiles objectAtIndex:i];
    [pendingTiles removeObject:t];
    return t;
}

- (void) dropTiles {
    float t_y_offset = (self.view.bounds.size.height/4) - (cHeight * line);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
        t_y_offset = 10;
    } else {
        t_y_offset = 80;
    }
    WordTile *t = [self randomPendingTile];
    if (t == nil) {
        [self displayAuthor];
        return;
    }
    CGFloat damping = 0.60;
    [UIView animateWithDuration:0.20 delay:0 usingSpringWithDamping: damping  initialSpringVelocity: 1.0 options:0 animations:^{
        t.frame = CGRectMake(t.frame.origin.x, t.location.y + t_y_offset, t.frame.size.width, t.frame.size.height);
    } completion:^(BOOL finished) {
        if ([pendingTiles count] <= 0) {
            [self displayAuthor];
            return;
        }
        [self dropTiles];
    }];
}

- (void) displayQuote
{
    self.view.backgroundColor = [[AppContext sharedContext] bgColor];
    self.view.backgroundColor = [UIColor whiteColor];

    tileArray    = [[NSMutableArray alloc] init];
    targetsArray = [[NSMutableArray alloc] init];
    pendingTiles = [[NSMutableArray alloc] init];

    quoteColor   = [UIColor colorWithHexString:@"17b680"];
    quoteFont    = [[AppContext sharedContext] fontForType:FONT_TYPE_WIN_TILE];
    float spacing = 10.0f;
    float margin_left = 20.0;
    cX      = margin_left;
    cY      = 0.0f;
    cHeight = 0.0f;
    line    = 0;
    
    CGSize max = CGSizeMake(self.view.bounds.size.width,
                            self.view.bounds.size.height);
    for (NSString *s in self.quote[@"words"]) {
        CGRect titleLabelRect = [s boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:quoteFont} context:nil];
        NSLog(@"%@ %f %f",    s,
                              titleLabelRect.size.width,
                              titleLabelRect.size.height);
        cHeight = titleLabelRect.size.height;
        if ((cX + titleLabelRect.size.width + margin_left + 20) > (self.view.frame.size.width - 40)) {
            cX  = margin_left;
            line = line + 1;
            cY += cHeight;
        }
        WordTile *t = [self startTileWithString:s:cX :cY];
        t.line = line;
        
        t.customColors = YES;
        t.fgColor = [[AppContext sharedContext] fgColor];
        t.bgColor = [[AppContext sharedContext] bgColor];
        t.bgColor = [UIColor whiteColor];

        t.location = CGPointMake(cX, cY);
        [tileArray addObject:t];
        [pendingTiles addObject:t];
        cX += titleLabelRect.size.width;
        cX += spacing;
    }
    [self dropTiles];
    return;
}

- (void) wikipedia : (id) sender
{
    WIkipediaViewController *wvc = [[WIkipediaViewController alloc] init];
    wvc.view.frame = self.view.bounds;
    UINavigationController *n = [[UINavigationController alloc] initWithNavigationBarClass:[ExpandingNavigationBar class] toolbarClass:nil];
    [n pushViewController:wvc animated:NO];

    [self presentViewController:n animated:YES completion:^{
        [wvc loadAddress:[self.quote objectForKey:@"author_url"]];
        n.topViewController.title = self.quote[@"author"];
    }];
}

- (void) finished : (id) sender
{
    buttonNext.hidden = YES;
    
    if (self.delegate != nil)
    {
        [self.delegate setupBoard];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        historyMode = NO;
    }
    return self;
}

- (void) ad
{
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = MY_INTERSTITIAL_UNIT_ID;
    interstitial_.delegate = self;
    GADRequest *r = [GADRequest request];
    /* IF DEBUG ADS */
    r.testDevices = [NSArray arrayWithObjects:
                     [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                     nil];
    [interstitial_ loadRequest:r];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    sv = [[UIScrollView alloc] initWithFrame:self.view.frame];
    sv.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sv];
    
    quoteColor   = [UIColor colorWithHexString:@"17b680"];
    quoteFont    = [[AppContext sharedContext] fontForType:FONT_TYPE_WIN_TILE];

    float margin= 20.0;
    buttonNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonNext.frame = CGRectMake(40, 140, 240, 30);
    [buttonNext addTarget:self action:@selector(finished:) forControlEvents:UIControlEventTouchUpInside];
    [buttonNext setTitle:@"" forState:UIControlStateNormal];
    buttonNext.titleLabel.font = [UIFont systemFontOfSize:46.0];
    
    CGSize max = CGSizeMake(self.view.bounds.size.width,
                            self.view.bounds.size.height);

    CGRect titleLabelRect = [@"Next" boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:buttonNext.titleLabel.font} context:nil];
    buttonNext.frame = CGRectMake(self.view.bounds.size.width - titleLabelRect.size.width - margin,
                                  self.view.bounds.size.height - titleLabelRect.size.height - margin,
                                  titleLabelRect.size.width,
                                  titleLabelRect.size.height);
    buttonNext.opaque = NO;
    buttonNext.alpha = 0.0;
    
    [sv addSubview:buttonNext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
/* Manage / Handle Ad Requests  -- going to try just interstitial's for now */
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    @try {
        [interstitial_ presentFromRootViewController:self];
    } @catch (NSException *e) {
        
    }
}


@end
