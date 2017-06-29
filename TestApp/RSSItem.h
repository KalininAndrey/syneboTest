//
//  RSSItem.h
//  TestApp
//
//  Created by Andrey Kalinin on 6/24/17.
//  Copyright © 2017 Andrey Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSItem : NSObject

@property(nonatomic, strong)NSString* title;
@property(nonatomic, strong)NSString* date;
@property(nonatomic, strong)NSString* link;

@end
