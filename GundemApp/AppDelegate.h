//
//  AppDelegate.h
//  NewsApp
//
//  Created by yvzyldrm on 8/22/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#define ADS_HEIGHT
#import <OneSignal/OneSignal.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OneSignal *oneSignal;


@end
