//
//  FirstViewController.m
//  TestApp
//
//  Created by Andrey Kalinin on 6/24/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property(nonatomic, weak)IBOutlet UILabel* nameLabel;
@property(nonatomic, weak)IBOutlet UILabel* dateLabel;
@property(nonatomic, weak)IBOutlet UILabel* feedLabel;

@property(nonatomic, strong)NSTimer* dateRefreshTimer;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameLabel.text = @"Kalinin Andrey";
    self.feedLabel.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRSSTitle:) name:@"RSSSelected" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    
    self.dateRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer)
    {
        NSString* dateStr = [formatter stringFromDate:[NSDate date]];
        self.dateLabel.text = dateStr;
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.dateRefreshTimer invalidate];
    self.dateRefreshTimer = nil;
}

-(void)addRSSTitle:(NSNotification *) notification
{
    NSString* title = notification.userInfo[@"titleKey"];
    if (title.length > 0)
    {
        self.feedLabel.text = title;
    }
}

@end
