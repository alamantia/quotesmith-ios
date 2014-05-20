//
//  WIkipediaViewController.m
//  QuoteSmith
//
//  Created by waffles on 5/12/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "WIkipediaViewController.h"

@interface WIkipediaViewController () {
    UIWebView *webview;
    UIActivityIndicatorView  *activity;
}
@end

@implementation WIkipediaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activity removeFromSuperview];
}

- (void) loadAddress : (NSString *) address
{
    webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webview.delegate = self;
    webview.scalesPageToFit = YES;
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:address]]];
     [self.view addSubview:webview];
    NSLog(@"Trying to load %@", address);
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.center = self.view.center;
    [activity startAnimating];
    [self.view addSubview:activity];

}

- (IBAction) done  :(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(done:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
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
