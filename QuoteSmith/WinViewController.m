//
//  WinViewController.m
//  QuoteSmith
//
//  Created by waffles on 4/29/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.

#import "WinViewController.h"
#import "UIColor+Expanded.h"
#import "WordTile.h"

@interface WinViewController () {
    UIButton *buttonNext;
    NSMutableArray *tileArray;
    NSMutableArray *targetsArray;
    NSMutableArray *pendingTiles;
    int animation_line;
    UIFont   * quoteFont;
    UIColor  * quoteColor;
    float cHeight;
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
    t.mode = TILE_MODE_GAME;
    CGRect fr = t.frame;
    fr.origin.x = x;
    fr.origin.y = -100; // inital x position higher up
    t.frame = fr;
    [t setString:s];
    [self.view addSubview:t];
    return t;
}

// display some author detail
- (void) displayAuthor
{
    
}

- (WordTile *) randomPendingTile
{
    WordTile *t = nil;
    if ([pendingTiles count] <= 0) {
        return nil;
    }
    int i = rand() % [pendingTiles count];
    t = [pendingTiles objectAtIndex:i];
    return t;
}

- (void) dropTiles {
    // do a very simple animation
    float t_y_offset = (self.view.bounds.size.height/4) - (cHeight * line);
    WordTile *t = [self randomPendingTile];
    if (t == nil)
        return;
    [UIView animateWithDuration:0.25 animations:^{
        t.frame = CGRectMake(t.frame.origin.x, t.location.y + t_y_offset, t.frame.size.width, t.frame.size.height);
    } completion:^(BOOL finished) {
        if ([pendingTiles count] <= 0) {
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
    float cX      = 0.0f;
    float cY      = 0.0f;
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
        if ((cX + titleLabelRect.size.height) > self.view.frame.size.width) {
            cX  = 0.0;
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
    buttonNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonNext.frame = CGRectMake(40, 140, 240, 30);
    [buttonNext addTarget:self action:@selector(finished:) forControlEvents:UIControlEventTouchUpInside];
    [buttonNext setTitle:@"Next" forState:UIControlStateNormal];
    buttonNext.titleLabel.font = [UIFont systemFontOfSize:46.0];
    
    CGSize max = CGSizeMake(self.view.bounds.size.width,
                            self.view.bounds.size.height);

    CGRect titleLabelRect = [@"Next" boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:buttonNext.titleLabel.font} context:nil];
    buttonNext.frame = CGRectMake(self.view.bounds.size.width - titleLabelRect.size.width,
                                  self.view.bounds.size.height - titleLabelRect.size.height,
                                  titleLabelRect.size.width,
                                  titleLabelRect.size.height);
    
    [self.view addSubview:buttonNext];
    // Do any additional setup after loading the view.
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
