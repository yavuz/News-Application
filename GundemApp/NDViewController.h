//
//  NDViewController.h
//  NewsApp
//
//  Created by yvzyldrm on 08/03/14.
//  Copyright (c) 2014 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DescView.h"
#import "GundemNews.h"
#import "NWebController.h"
#import "UIControl+SoundForControlEvents.h"

@class NListController;

@interface NDViewController : UIViewController {
    UIActivityViewController *ActivityView;
}

@property (nonatomic,strong) GundemNews *previousNews;
@property (nonatomic,strong) GundemNews *currentNews;
@property (nonatomic,strong) GundemNews *nextNews;

@property (nonatomic,strong) DescView* previousNewsView;
@property (nonatomic,strong) DescView* currentNewsView;
@property (nonatomic,strong) DescView* nextNewsView;

@property (nonatomic,weak) NListController* delegate;
@property (nonatomic,strong) NSString *nlink;

- (void)newsRead:(NSString *)nurl;

@end
