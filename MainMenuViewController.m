//
//  MainMenuViewController.m
//  QuoteSmith
//
//  Created by waffles on 6/23/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.

#import "MainMenuViewController.h"
#import "NavBarButton.h"
#import "UIColor+Expanded.h"
#import "GameViewController.h"
#import "MPTextReavealLabel.h"
#import "RectButton.h"
#import "MenuTableViewCell.h"

#define MENU_CELL_ID @"MENU-CELL"

@interface MainMenuViewController () {
    MPTextReavealLabel *logoLabel;
    GameViewController *gvc;
    
    UITableView *menuTableView;
    
    RectButton *buttonMainMenu;
    RectButton *buttonHistory;
    RectButton *buttonHelp;
}
@end

@implementation MainMenuViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [menuTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self beginGame];
    }
    if (indexPath.row == 1) {
            [self performSegueWithIdentifier: @"goHistory" sender: self];
    }
    if (indexPath.row == 2) {
        [self performSegueWithIdentifier: @"goTutorial" sender: self];
    }
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:MENU_CELL_ID];
    
    switch (indexPath.row) {
        case 0: {
            [cell setTitle:@"Start"];
            break;
        }
        case 1: {
            [cell setTitle:@"History"];
            break;
        }
        case 2: {
            [cell setTitle:@"Tutorial"];
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(MenuTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setTitle:@""];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    //self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.topViewController.title = @"Quote Smith";
    [menuTableView reloadData];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) beginGame
{
    gvc = [[GameViewController alloc] init];
    UINavigationController *n = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:nil];
    [n pushViewController:gvc animated:NO];
    n.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    n.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:n animated:YES completion:^{
        
    }];
    return;
}

- (void) beginHelp : (id) sender
{
    return;
}

- (void) beginHistory : (id) sender
{
    
}

- (void) addLogoLegal
{
    UIFont *logoFont =  [UIFont fontWithName:@"HelveticaNeue-light" size:56];
    CGSize max = CGSizeMake(self.view.bounds.size.width - 40,
                            self.view.bounds.size.height);

    CGRect quoteLabelRect = [@"Quote " boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:logoFont} context:nil];
    
    CGRect smithLabelRect = [@"Smith" boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:logoFont} context:nil];
    
    float totalWidth = quoteLabelRect.size.width + smithLabelRect.size.width;
    
    float labelX = (self.view.frame.size.width/2) - totalWidth/2;
    float tableY = 120 + quoteLabelRect.size.height + 20;
    
    MPTextReavealLabel *label=[[MPTextReavealLabel alloc] initWithFrame:CGRectMake(labelX, 80, 280, 160)];
    label.tag=3838;
    label.lineWidth=1;
    label.attributedText=[[NSAttributedString alloc] initWithString:@"Quote " attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : logoFont}];
    [self.view addSubview:label];

    
    MPTextReavealLabel *labelSmith=[[MPTextReavealLabel alloc] initWithFrame:CGRectMake(quoteLabelRect.size.width + labelX, 80, 280, 160)];
    labelSmith.lineWidth=1;

    labelSmith.attributedText=[[NSAttributedString alloc] initWithString:@"Smith" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : logoFont}];
    [self.view addSubview:labelSmith];

    [label animateWithDuration:1.0];
    [labelSmith animateWithDuration:1.0];
    [self setupTableView:tableY];
}

- (void) setupTableView  : (float) positionY {
    menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, positionY, self.view.frame.size.width
                                                            , self.view.frame.size.height - positionY)];
    menuTableView.delegate = self;
    menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    menuTableView.scrollEnabled = NO;
    menuTableView.dataSource = self;
    [menuTableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:MENU_CELL_ID];
    [self.view addSubview:menuTableView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self addLogoLegal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

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
