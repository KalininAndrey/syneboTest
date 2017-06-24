//
//  SecondViewController.m
//  TestApp
//
//  Created by Andrey Kalinin on 6/24/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import "RSSViewController.h"
#import "NetworkManager.h"
#import "RSSItem.h"

@interface RSSViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak)IBOutlet UISegmentedControl* segmentedControl;
@property(nonatomic, weak)IBOutlet UITableView* tableView;

@property(nonatomic, strong)NSArray<RSSItem*>* businessData;
@property(nonatomic, strong)NSArray<RSSItem*>* entertainmentData;
@property(nonatomic, strong)NSArray<RSSItem*>* enviromentData;

@property(nonatomic, weak)NSArray<RSSItem*>* tableData;

@property(nonatomic, assign)NSUInteger activityCount;
@property(nonatomic, strong)UIActivityIndicatorView* activity;

@end

static NSUInteger const kReloadDataTime = 5;

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self loadData];
}


-(void)loadData
{
    [self reloadBuisnessData];
    [self reloadEnvironmentData];
    [self reloadEntertainmentData];
}

-(NSArray*)tableData
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        return self.businessData;
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        return [self.entertainmentData arrayByAddingObjectsFromArray:self.enviromentData];
    }
    else
    {
        NSAssert(NO, @"Invalid segment control index");
        return nil;
    }
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableCell"];
    RSSItem* item = self.tableData[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.date;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem* item = self.tableData[indexPath.row];
    
    NSDictionary *userInfo = @{@"titleKey" : item.title};
    [[NSNotificationCenter defaultCenter] postNotificationName: @"RSSSelected" object:nil userInfo:userInfo];
}

#pragma mark Actions

-(IBAction)segmentChanged:(id)sender
{
    [self.tableView reloadData];
}

#pragma mark Data loading

-(void)reloadBuisnessData
{
    [self showActivity];
    [[NetworkManager sharedManager] getBusinessFeedWithResultBlock:^(NSError *error, NSArray *results)
     {
         [self hideActivity];

         if (error == nil)
         {
             self.businessData = results;
             [self.tableView reloadData];
         }
         else
         {
             NSLog(@"Error:%@", error.localizedDescription);
         }

         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kReloadDataTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self reloadBuisnessData];
         });

     }];
}


-(void)reloadEnvironmentData
{
    [self showActivity];
    [[NetworkManager sharedManager] getEnvironmentFeedWithResultBlock:^(NSError *error, NSArray *results)
     {
         [self hideActivity];

         if (error == nil)
         {
             self.enviromentData = results;
             [self.tableView reloadData];
         }
         else
         {
             NSLog(@"Error:%@", error.localizedDescription);
         }
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kReloadDataTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self reloadEnvironmentData];
         });
     }];
}

-(void)reloadEntertainmentData
{
    [self showActivity];
    [[NetworkManager sharedManager] getEntertainmentFeedWithResultBlock:^(NSError *error, NSArray *results)
     {
         [self hideActivity];

         if (error == nil)
         {
             self.entertainmentData = results;
             [self.tableView reloadData];
         }
         else
         {
             NSLog(@"Error:%@", error.localizedDescription);
         }
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kReloadDataTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self reloadEntertainmentData];
         });

     }];
}

-(void)showActivity
{
    self.activityCount++;
    if (self.activityCount == 1) //Don't show 3 activity indicators in one screen
    {
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activity.center = self.view.center;
        [self.activity startAnimating];
        
        [self.view addSubview:self.activity];
    }
}

-(void)hideActivity
{
    self.activityCount--;
    if (self.activityCount == 0) //Hide activity only when all loadings are done
    {
        [self.activity removeFromSuperview];
        self.activity = nil;
    }

}

@end