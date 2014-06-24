//
//  MainMenuViewController.m
//  QuoteSmith
//
//  Created by waffles on 6/23/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "MainMenuViewController.h"
#import "NavBarButton.h"
#import "UIColor+Expanded.h"
#import "GameViewController.h"

@interface MainMenuViewController () {
    GameViewController *gvc;
}
@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void) viewWillAppear:(BOOL)animated
{

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.topViewController.title = @"Quote Smith";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
