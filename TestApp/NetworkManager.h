//
//  NetworkManager.h
//  TestApp
//
//  Created by Andrey Kalinin on 6/24/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSItem;

typedef NS_ENUM(NSUInteger, FeedType)
{
    FeedTypeBusiness,
    FeedTypeEntertainment,
    FeedTypeEnvironment,

};

@interface NetworkManager : NSObject

+ (instancetype)sharedManager;

-(void)getFeedWithType:(FeedType)type resultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock;

//-(void)getBusinessFeedWithResultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock;
//-(void)getEntertainmentFeedWithResultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock;
//-(void)getEnvironmentFeedWithResultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock;

@end
