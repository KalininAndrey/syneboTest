//
//  DetailsViewController.m
//  TestApp
//
//  Created by Andrey Kalinin on 6/24/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@property(nonatomic, weak)IBOutlet UIWebView* webView;

@end

@implementation DetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.link.length > 0)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.link]];
        [self.webView loadRequest:request];
    }
}

-(void)setLink:(NSString *)link
{
    _link = link;
    if (self.webView != nil)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.link]];
        [self.webView loadRequest:request];
    }
}

-(IBAction)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
