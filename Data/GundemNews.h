//
//  GundemNews.h
//  NewsApp
//
//  Copyright (c) 2014 yvzyldrm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface GundemNews : NSObject

+ (instancetype)newsWithData:(NSDictionary*)data;
+ (instancetype)newsWithDBResultSet:(FMResultSet*)resultSet;

@property (nonatomic) NSUInteger itemID;
@property (nonatomic,copy) NSString* channelName;
@property (nonatomic,copy) NSString* channelCategory;
@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* content;
@property (nonatomic,copy) NSString* dateString;
@property (nonatomic,copy) NSString* imageUrl;
@property (nonatomic,copy) NSString* link;

@end
