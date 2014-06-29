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
#import "AppContext.h"
#import "WinViewController.h"

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
    [self.historyTableView registerNib:[UINib nibWithNibName:HISTORY_CELL_AUTO_ID bundle:nil] forCellReuseIdentifier:HISTORY_CELL_AUTO_ID];
    self.navigationController.topViewController.title = @"History";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"ffffff"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *quote = [Quotes quoteforIndex:indexPath.row];
    return [HistoryTableViewCell heightForQuote:quote inFrame:tableView.frame];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WinViewController *win = [[WinViewController alloc] init];
    win.view.backgroundColor = [[AppContext sharedContext] bgColor];
    win.view.backgroundColor = [UIColor whiteColor];
    [win historyMode];
    win.quote = [Quotes quoteforIndex:indexPath.row];
    win.modalPresentationStyle = UIModalPresentationCustom;
    UINavigationController *n = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:nil];
    [n pushViewController:win animated:NO];
    [self.navigationController pushViewController:win animated:YES];
    [win displayQuote];
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryTableViewCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier:HISTORY_CELL_AUTO_ID];
    NSDictionary *quote = [Quotes quoteforIndex:indexPath.row];
    cell.authorLabel.text = quote[@"author"];
    cell.quoteLabel.text = quote[@"quote"];
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
