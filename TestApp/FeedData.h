//
//  FeedData.h
//  TestApp
//
//  Created by Andrey Kalinin on 6/29/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"

@class FeedData;

@protocol FeedDataDelegate <NSObject>

@optional

-(void)feedStartsLoading;
-(void)feedFailedLoading;

@required

-(void)feedHasNewData:(FeedData*)feed;

@end

@interface FeedData : NSObject

@property(nonatomic, assign, readonly) FeedType type;
@property(nonatomic, strong, readonly) NSArray* feed;

@property(nonatomic, assign) NSTimeInterval refreshtimeout;
@property(nonatomic, assign)BOOL refreshing;

@property(nonatomic, weak)id <FeedDataDelegate> delegate;

-(instancetype)initWithType:(FeedType)type;

@end
