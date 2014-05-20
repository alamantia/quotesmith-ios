//
//  WinViewController.m
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.

#import "WinViewController.h"
#import "UIColor+Expanded.h"
#import "WIkipediaViewController.h"
#import "WordTile.h"

@interface WinViewController () {
    UIButton *buttonNext;
    UIButton *buttonWikipedia;
    NSMutableArray *tileArray;
    NSMutableArray *targetsArray;
    NSMutableArray *pendingTiles;
    int animation_line;
    UITextView *quoteInfo;
    UIFont   * quoteFont;
    UIColor  * quoteColor;
    // bad practice but i'm lazy tonight!
    float cHeight;
    float cY;
    float cX;
    int line;
}
@end

@implementation WinViewController

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
    [self.view addSubview:t];
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

// display some author detail
- (void) displayAuthor
{
    NSString *s = [NSString stringWithFormat:@"-%@",[self.quote objectForKey:@"author"]];
    CGSize max = CGSizeMake(self.view.bounds.size.width,
                            self.view.bounds.size.height);
    CGRect titleLabelRect = [s boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:quoteFont} context:nil];
    
    float padding = 40;
    float padding_height = 20;
    float t_y_offset = (self.view.bounds.size.height/4) - (cHeight * line);

    WordTile *t = [[WordTile alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - titleLabelRect.size.width - padding,
                                                             -100,
                                                             titleLabelRect.size.width,
                                                             titleLabelRect.size.height)];
    
    t.mode = TILE_MODE_WIN;
    [t setString:s];
    [self.view addSubview:t];
    
    CGFloat damping = 0.60;
    [UIView animateWithDuration:0.20 delay:0 usingSpringWithDamping: damping  initialSpringVelocity: 1.0 options:0 animations:^{
        t.frame = CGRectMake(self.view.bounds.size.width - titleLabelRect.size.width - padding,
                             t_y_offset + cY + cHeight + padding_height,
                             titleLabelRect.size.width,
                             titleLabelRect.size.height);
        // update cY
        cY = t_y_offset + cY + cHeight + padding_height + cHeight;
    } completion:^(BOOL finished) {
        if ([pendingTiles count] <= 0) {
            [self displayNext];
            return;
        }
        [self dropTiles];
    }];

    
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
    WordTile *t = [self randomPendingTile];
    if (t == nil) {
        [self displayNext];
        [self displayAuthor];
        return;
    }
    CGFloat damping = 0.60;
    [UIView animateWithDuration:0.20 delay:0 usingSpringWithDamping: damping  initialSpringVelocity: 1.0 options:0 animations:^{
        t.frame = CGRectMake(t.frame.origin.x, t.location.y + t_y_offset, t.frame.size.width, t.frame.size.height);
    } completion:^(BOOL finished) {
        if ([pendingTiles count] <= 0) {
            [self displayNext];
            [self displayAuthor];
            return;
        }
        [self dropTiles];
    }];
}

- (void) displayQuote
{
    tileArray    = [[NSMutableArray alloc] init];
    targetsArray = [[NSMutableArray alloc] init];
    pendingTiles = [[NSMutableArray alloc] init];

    quoteColor   = [UIColor colorWithHexString:@"17b680"];
    quoteFont    = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:40.0];
    float spacing = 10.0f;
    float margin_left = 20.0;
    cX      = margin_left;
    cY      = 0.0f;
    cHeight = 0.0f;
    line = 0;
    CGSize max = CGSizeMake(self.view.bounds.size.width,
                            self.view.bounds.size.height);
    for (NSString *s in self.quote[@"words"]) {
        CGRect titleLabelRect = [s boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:quoteFont} context:nil];
        NSLog(@"%@ %f %f",    s,
                              titleLabelRect.size.width,
                              titleLabelRect.size.height);
        cHeight = titleLabelRect.size.height;
        if ((cX + titleLabelRect.size.height + margin_left) > self.view.frame.size.width) {
            cX  = margin_left;
            line = line + 1;
            cY += cHeight;
        }
        WordTile *t = [self startTileWithString:s:cX :cY];
        t.line = line;
        t.location = CGPointMake(cX, cY);
        [tileArray addObject:t];
        [pendingTiles addObject:t];
        cX += titleLabelRect.size.width;
        cX += spacing;
    }
    [self dropTiles];
    return;
}

// open a webview to the relevant wikipedia page
- (void) wikipedia : (id) sender
{
    WIkipediaViewController *wvc = [[WIkipediaViewController alloc] init];
    wvc.view.frame = self.view.bounds;
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:wvc];
    n.navigationBar.translucent = NO;
    [self presentViewController:n animated:YES completion:^{
        [wvc loadAddress:[self.quote objectForKey:@"author_url"]];
    }];
}

- (void) finished : (id) sender
{
    buttonNext.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    quoteColor   = [UIColor colorWithHexString:@"17b680"];
    quoteFont    = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:40.0];

    float margin= 20.0;
    buttonNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonNext.frame = CGRectMake(40, 140, 240, 30);
    [buttonNext addTarget:self action:@selector(finished:) forControlEvents:UIControlEventTouchUpInside];
    [buttonNext setTitle:@"Next" forState:UIControlStateNormal];
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
    
    [self.view addSubview:buttonNext];

    
    NSString *wikiString = [NSString stringWithFormat:@"Learn more about %@",
                            [self.quote objectForKey:@"author"]];
    buttonWikipedia = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonWikipedia.frame = CGRectMake(0, 140, 240, 30);
    [buttonWikipedia addTarget:self action:@selector(wikipedia:) forControlEvents:UIControlEventTouchUpInside];
    [buttonWikipedia setTitle:wikiString forState:UIControlStateNormal];
    buttonWikipedia.titleLabel.font = [UIFont systemFontOfSize:24];
    
    
    titleLabelRect = [wikiString boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:buttonWikipedia.titleLabel.font} context:nil];
    buttonWikipedia.frame = CGRectMake(margin,
                                  self.view.bounds.size.height - titleLabelRect.size.height - margin,
                                  titleLabelRect.size.width,
                                  titleLabelRect.size.height);

    [self.view addSubview:buttonWikipedia];

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

@end
