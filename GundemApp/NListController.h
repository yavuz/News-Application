//
//  NListController.h
//  NewsApp
//
//  Created by yvzyldrm on 8/26/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"
#import "FMDatabase.h"
#import "MBProgressHUD.h"
#import "FMLabel.h"
#import "GundemNews.h"
#import "UIControl+SoundForControlEvents.h"
//#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>

@interface NListController : UITableViewController<MWFeedParserDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate> {
    MWFeedParser *feedParser;
    NSMutableArray *tableData;
    NSMutableArray *parsedItems;
    NSMutableDictionary *ndata;
    NSTimer *ftimer;
    MBProgressHUD *HUD;
    
    FMDatabase *database;
    NSInteger insertnumber;
    IBOutlet UITableView *nlistTable;
    float currentVersion;
}

@property (nonatomic,retain) IBOutlet UITableView *nlistTable;
@property (nonatomic,strong) NSMutableDictionary *ndata;
@property CGFloat firstCellLabelWidth;
@property CGFloat firstCellDescWidth;
@property BOOL newsImageState;
@property (nonatomic,retain) UIRefreshControl *nrefresh;


- (void)setUpImageBackButton;
- (void)popCurrentViewController;
- (void)hideNewsImages;
- (void)setUpDatabase;
- (void) startFeedParse: (NSTimer *) theTimer;
- (NSString *)slug: (NSString *)text;
- (NSMutableArray *)getNews: (NSInteger)nnid;

- (BOOL)nextNewsAvailableForNews:(GundemNews*)newsData;
- (BOOL)previousNewsAvailableForNews:(GundemNews*)newsData;

- (GundemNews*)nextNewsForNews:(GundemNews*)newsData;
- (GundemNews*)previousNewsForNews:(GundemNews*)newsData;

@end
