//
//  GundemNews.m
//  NewsApp
//
//  Copyright (c) 2014 yvzyldrm. All rights reserved.
//

#import "GundemNews.h"
#import "FMDatabase.h"

@implementation GundemNews

+ (instancetype)newsWithData:(NSDictionary*)data {
	GundemNews* news = GundemNews.new;
	[news fillWithData:data];
	return news;
}
+ (instancetype)newsWithDBResultSet:(FMResultSet*)resultSet {
	return [self newsWithData:(NSDictionary*)resultSet];
}

- (BOOL)isEqual:(GundemNews*)object {
	if (object == self) return YES;
	if (object.itemID == self.itemID) return YES;
	return NO;
}

- (void)fillWithData:(NSDictionary*)data {
	self.itemID = [data[@"id"] integerValue];
	self.channelName = data[@"newname"];
	self.channelCategory = data[@"newsubname"];
	self.title = data[@"ntitle"];
	self.content = data[@"ndesc"];
	self.dateString = data[@"ndate"];
    self.imageUrl = data[@"nimage"];
    self.link = data[@"nlink"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@[%d] - %@ %@ %@", NSStringFromClass(self.class), (int)self.itemID, self.title ,self.dateString,self.imageUrl];
}

@end
