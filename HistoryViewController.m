//
//  HistoryViewController.m
//  QuoteSmith
//
//  Created by waffles on 6/26/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//
#import "Quotes.h"
#import "HistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "UIColor+Expanded.h"

#define HISTORY_CELL_ID @"HistoryCell"
#define HISTORY_CELL_AUTO_ID @"HistoryTableViewCell"

@interface HistoryViewController () {

}
@property(weak) IBOutlet UITableView *historyTableView;
@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.topViewController.title = @"History";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"ffffff"];
    [self.historyTableView registerNib:[UINib nibWithNibName:HISTORY_CELL_AUTO_ID bundle:nil] forCellReuseIdentifier:HISTORY_CELL_AUTO_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *quote = [Quotes quoteforIndex:indexPath.row];
    // quote[@"quote"];
    return 400.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryTableViewCell *cell = [tableView
                               dequeueReusableCellWithIdentifier:HISTORY_CELL_AUTO_ID];
    NSDictionary *quote = [Quotes quoteforIndex:indexPath.row];
    cell.textLabel.text = quote[@"quote"];
    NSLog(@"Setting quote %@", quote[@"quote"]);
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(HistoryTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Quotes lastQuoteIndex];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


@end
