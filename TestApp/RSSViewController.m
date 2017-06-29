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
#import "DetailsViewController.h"
#import "FeedData.h"

typedef NS_ENUM(NSUInteger, TableMode)
{
    TableModeBusiness,
    TableModeEandE,
};


@interface RSSViewController ()<UITableViewDelegate, UITableViewDataSource, FeedDataDelegate>

@property(nonatomic, weak)IBOutlet UISegmentedControl* segmentedControl;
@property(nonatomic, weak)IBOutlet UITableView* tableView;

@property(nonatomic, strong)NSArray<RSSItem*>* businessData;
@property(nonatomic, strong)NSArray<RSSItem*>* entertainmentData;
@property(nonatomic, strong)NSArray<RSSItem*>* enviromentData;

@property(nonatomic, weak)NSArray<RSSItem*>* tableData;

@property(nonatomic, assign)NSUInteger activityCount;
@property(nonatomic, strong)UIActivityIndicatorView* activity;

@property(nonatomic, assign)TableMode tableMode;

@property(nonatomic, strong)FeedData* businessFeeed;
@property(nonatomic, strong)FeedData* entertainmentFeeed;
@property(nonatomic, strong)FeedData* enviromentFeeed;

@end



@implementation RSSViewController
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    self.tableMode = TableModeBusiness;
    
    self.businessFeeed      = [[FeedData alloc] initWithType:FeedTypeBusiness];
    self.enviromentFeeed    = [[FeedData alloc] initWithType:FeedTypeEnvironment];
    self.entertainmentFeeed = [[FeedData alloc] initWithType:FeedTypeEntertainment];

    self.businessFeeed.delegate      = self;
    self.enviromentFeeed.delegate    = self;
    self.entertainmentFeeed.delegate = self;
    
    self.businessData      = [NSArray new];
    self.entertainmentData = [NSArray new];
    self.enviromentData    = [NSArray new];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableMode = self.tableMode;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.businessFeeed.refreshing      = NO;
    self.entertainmentFeeed.refreshing = NO;
    self.enviromentFeeed.refreshing    = NO;
}

-(NSArray<RSSItem*>*)tableData
{
    switch (self.tableMode)
    {
        case TableModeBusiness:
            return self.businessData;
            break;
        case TableModeEandE:
            return [self.entertainmentData arrayByAddingObjectsFromArray:self.enviromentData];
            break;
    }
}

-(void)setTableMode:(TableMode)tableMode
{
    _tableMode = tableMode;
    switch (tableMode)
    {
        case TableModeBusiness:
            self.businessFeeed.refreshing = YES;
            
            self.entertainmentFeeed.refreshing = NO;
            self.enviromentFeeed.refreshing    = NO;
            break;
            
        case TableModeEandE:
            self.businessFeeed.refreshing = NO;
            
            self.entertainmentFeeed.refreshing = YES;
            self.enviromentFeeed.refreshing    = YES;

            break;
    }
    [self.tableView reloadData];
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
    
    cell.textLabel.text       = item.title;
    cell.detailTextLabel.text = item.date;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem* item = self.tableData[indexPath.row];
    
    NSDictionary *userInfo = @{@"titleKey" : item.title};
    [[NSNotificationCenter defaultCenter] postNotificationName: @"RSSSelected" object:nil userInfo:userInfo];
    
    DetailsViewController* detailsController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    detailsController.link = item.link;
    [self presentViewController:detailsController animated:YES completion:nil];
}

#pragma mark FeedDataDelegate

-(void)feedHasNewData:(FeedData *)feed
{
    [self hideActivity];
    if (feed.feed.count > 0)
    {
        [self setData:feed.feed forType:feed.type];
    }
}

-(void)feedStartsLoading
{
    [self showActivity];
}

-(void)feedFailedLoading
{
    [self hideActivity];
}


-(void)setData:(NSArray*)data forType:(FeedType)type
{
    switch (type)
    {
        case FeedTypeBusiness:
            self.businessData = data;
            break;
        case FeedTypeEnvironment:
            self.enviromentData = data;
            break;
        case FeedTypeEntertainment:
            self.entertainmentData = data;
            break;
    }
    [self reloadTable];
}


//Keep selection after reload
-(void)reloadTable
{
    NSIndexPath* selectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:selectedRow animated:YES scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark Activity

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

#pragma mark Actions

-(IBAction)segmentChanged:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        self.tableMode = TableModeBusiness;
    }
    else
    {
       self.tableMode = TableModeEandE;
    }
}

@end
