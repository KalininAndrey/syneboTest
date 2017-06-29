//
//  NetworkManager.m
//  TestApp
//
//  Created by Andrey Kalinin on 6/24/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import "NetworkManager.h"
#import "GDataXMLElement+Ext.h"
#import "RSSItem.h"

@interface NetworkManager() <NSURLSessionDelegate>
@end

@implementation NetworkManager
{
   NSURLSessionConfiguration* _sessionConfiguration;
   NSURLSession* _session;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static NetworkManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[NetworkManager alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionConfiguration.timeoutIntervalForRequest = 30;
        _session = [NSURLSession sessionWithConfiguration:_sessionConfiguration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    return self;
}


-(void)getEntertainmentFeedWithResultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock
{
    NSParameterAssert(resultBlock);
    [self getFeed:@"http://feeds.reuters.com/reuters/entertainment" resultBlock:resultBlock];
}


-(void)getEnvironmentFeedWithResultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock
{
    NSParameterAssert(resultBlock);
    [self getFeed:@"http://feeds.reuters.com/reuters/environment" resultBlock:resultBlock];
}


-(void)getBusinessFeedWithResultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock
{
    NSParameterAssert(resultBlock);

    [self getFeed:@"http://feeds.reuters.com/reuters/businessNews" resultBlock:resultBlock];
}

#pragma mark private

-(void)getFeed:(NSString*)feedLink resultBlock:(void (^)(NSError* error, NSArray<RSSItem*>* results))resultBlock
{
    NSMutableURLRequest* request = [NSMutableURLRequest new];
    request.URL = [NSURL URLWithString:feedLink];
    
//    static NSURLSessionDataTask* sessionTask = nil;
//    [sessionTask cancel]; 
    
    NSURLSessionDataTask* sessionTask = [_session dataTaskWithRequest:request
                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        if (error)
        {
            resultBlock(error, nil);
        }
        
        NSError* err;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:&err];

        NSArray *entries = [self parseRSS:doc.rootElement];
        
        resultBlock(err, entries);
    }];
    [sessionTask resume];
}


- (NSArray*)parseRSS:(GDataXMLElement *)rootElement
{
    NSMutableArray* rssItems = [NSMutableArray new];
    
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels)
    {
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items)
        {
            RSSItem* rssItem = [RSSItem new];
            
            rssItem.title = [item valueForChild:@"title"];
            rssItem.link = [item valueForChild:@"link"];
            rssItem.date = [item valueForChild:@"pubDate"];
            
            [rssItems addObject:rssItem];
        }
    }
    return [NSArray arrayWithArray:rssItems];
}

@end
