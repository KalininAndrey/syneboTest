//
//  FeedData.m
//  TestApp
//
//  Created by Andrey Kalinin on 6/29/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import "FeedData.h"

@interface FeedData()


@end

@implementation FeedData
{
    BOOL loading;
}



-(instancetype)initWithType:(FeedType)type;
{
    self = [super init];
    if (self)
    {
        _type = type;
        self.refreshing = NO;
        self.refreshtimeout = 5; //Default timeout
    }
    return self;
}


-(void)setRefreshing:(BOOL)refreshing
{
    if (refreshing == _refreshing)
    {
        return;
    }
    _refreshing = refreshing;
    if (refreshing == YES)
    {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
             [self loadData];
         });
    }
}

-(void)loadData
{
    //Only one request for each type
    if (loading)
    {
        NSLog(@"Already loading");
        return;
    }
    loading = YES;
    
    if ([self.delegate respondsToSelector:@selector(feedStartsLoading)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate feedStartsLoading];
        });
    }

    
    NSLog(@"start Load feed with type %zd", self.type);
    [[NetworkManager sharedManager] getFeedWithType:self.type resultBlock:^(NSError *error, NSArray<RSSItem *> *results)
     {
         if (error != nil)
         {
             NSLog(@"Error:%@", error.localizedDescription);
             if ([self.delegate respondsToSelector:@selector(feedFailedLoading)])
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.delegate feedFailedLoading];
                 });
             }
             
         }
         else if (results.count == 0)
         {
             NSLog(@"Empty RSS Feed for type: %zd", self.type);
             if ([self.delegate respondsToSelector:@selector(feedFailedLoading)])
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.delegate feedFailedLoading];
                 });
             }
             
         }
         else
         {
             _feed = results;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.delegate feedHasNewData:self];
             });
             
             if (self.refreshing)
             {
                 dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.refreshtimeout * NSEC_PER_SEC));
                 dispatch_after(t, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                     loading = NO;
                     [self loadData];
                 });
             }
         }
         NSLog(@"Finish Load feed with type %zd", self.type);
         
     }];
}

@end
