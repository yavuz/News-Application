//
//  NSourceViewController.h
//  NewsApp
//
//  Created by yvzyldrm on 9/12/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface NSourceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UINavigationBar *SourceNavigation;
    FMDatabase *database;
    NSMutableArray *tableData;
    NSMutableDictionary *ndata;
    IBOutlet UITableView *nsourcetable;
    IBOutlet UIButton *backbutton;
    IBOutlet UIView *statusColor;
}

- (void)setUpDatabase;
-(void)removeItem: (NSString*) title;
-(void)addItem: (NSString*) title;

@end
