//
//  ViewController.h
//  NewsApp
//
//  Created by yvzyldrm on 8/22/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *tableData;
    FMDatabase *database;
    NSMutableDictionary *ndata;
    IBOutlet UIImageView *nfavicon;
    IBOutlet UITableView *nTableView;
    float currentVersion;
}

@property (nonatomic) NSMutableDictionary *ndata;

- (void)setUpDatabase;

@end
