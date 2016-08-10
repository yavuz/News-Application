//
//  NListController.m
//  NewsApp
//
//  Created by yvzyldrm on 8/26/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import "NListController.h"
#import "NDViewController.h"
#import "NSString+HTML.h"
#import "MWFeedParser.h"
#import <QuartzCore/QuartzCore.h>
#import "GundemNews.h"
#import "UIImageView+FMNetworkImage.h"
#import "NInfoViewController.h"

@interface NListController ()

@end

@implementation NListController
@synthesize nlistTable;
@synthesize ndata;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setUpImageBackButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        [backButton setBackgroundImage:[UIImage imageNamed:@"leftarrow7.png"] forState:UIControlStateNormal];
    } else {
        [backButton setBackgroundImage:[UIImage imageNamed:@"leftarrow.png"] forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
}

- (void)setUpChangeImageButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 20)];
    
    if(self.newsImageState) {
        [backButton setBackgroundImage:[UIImage imageNamed:@"cimagedisabled.png"] forState:UIControlStateNormal];
    } else {
        [backButton setBackgroundImage:[UIImage imageNamed:@"cimage.png"] forState:UIControlStateNormal];
    }
    
    NSDictionary *tempconfig = [params valueForKey:@"ONEPAGESETTINGS"];
    NSInteger oneRSSPage = [[tempconfig valueForKey:@"OneRSSPage"] intValue];
    NSInteger ShowOneRSSPage = [[tempconfig valueForKey:@"ShowImageButton"] intValue];
    
    if(oneRSSPage == 0) {
        UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [backButton addTarget:self action:@selector(hideNewsImages) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = barBackButtonItem;
        self.navigationItem.hidesBackButton = YES;
    }
    
}

- (void)hideNewsImages {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hideNewsImage = [defaults boolForKey:@"hideNewsImage"];

    if(hideNewsImage == NO) {
        static NSString *CellIdentifier = @"NListCell";
        UITableViewCell *cellData = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIImageView *cNewsImageView = (UIImageView *)[cellData viewWithTag:105];
        
        cNewsImageView.imageURL = nil;
        [cNewsImageView setHidden:YES];

        UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 20)];
        [infoButton setBackgroundImage:[UIImage imageNamed:@"cimagedisabled.png"] forState:UIControlStateNormal];

        UIBarButtonItem *barinfoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        [infoButton addTarget:self action:@selector(hideNewsImages) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = barinfoButtonItem;

        self.newsImageState = YES;
        
        [defaults setBool:YES forKey: @"hideNewsImage"];
        [defaults synchronize];
    } else {

        UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 20)];
        [infoButton setBackgroundImage:[UIImage imageNamed:@"cimage.png"] forState:UIControlStateNormal];
        
        UIBarButtonItem *barinfoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        [infoButton addTarget:self action:@selector(hideNewsImages) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = barinfoButtonItem;
        
        self.newsImageState = NO;
        
        [defaults setBool:NO forKey: @"hideNewsImage"];
        [defaults synchronize];
    }
    
    [self.tableView reloadData];
}

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Reset and reparse
- (void)refresh {
    [ftimer invalidate];
	self.title = NSLocalizedString(@"ListUpdating",nil);
	[parsedItems removeAllObjects];
	[feedParser stopParsing];
    ftimer = [NSTimer scheduledTimerWithTimeInterval: 1.5 target:self selector:@selector(startFeedParse:) userInfo:nil repeats: NO];
	self.nlistTable.userInteractionEnabled = YES;
    
}

- (void)feedParserDidStart:(MWFeedParser *)parser {
    insertnumber = 0;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	//self.title = info.title;
}

- (NSString *)replaceHtml: (NSString *)html tagitem:(NSString *) tag replaceitem:(NSString *) rdata {
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString: html];
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:[NSString stringWithFormat:@"<%@", tag]  intoString: NULL];
        // find end of tag
        [theScanner scanUpToString: @">" intoString: &text];
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat: @"%@>", text]
                                               withString: rdata];
    } // while //
    
    return html;
}

- (NSString *)imagenHtml: (NSString *)html tagitem:(NSString *) tag {
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString: html];
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:[NSString stringWithFormat:@"<%@", tag]  intoString: NULL];
        // find end of tag
        [theScanner scanUpToString: @">" intoString: &text];
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat: @"%@>", text]
                                               withString: @" "];
    } // while //
    
    return html;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    NSLog(@"%@",item);
    [database open];
	if (item && insertnumber < 50){
        [parsedItems addObject:item];
        //insertdate
        NSDate* nDate = [NSDate date];
        NSString *rsscontent = @"";
        if(item.content) {
            item.content = [item.content stringByReplacingOccurrencesOfString:@"src=\"//" withString:@"src=\"http://"];
            item.content = [item.content stringByReplacingOccurrencesOfString:@"src=\"://" withString:@"src=\"http://"];
            rsscontent = item.content;
        } else {
            item.summary = [item.summary stringByReplacingOccurrencesOfString:@"src=\"//" withString:@"src=\"http://"];
            item.summary = [item.summary stringByReplacingOccurrencesOfString:@"src=\"://" withString:@"src=\"http://"];
            rsscontent = item.summary;
        }

        //NSString *tsummary = [self imagenHtml:[self imagenHtml:[self imagenHtml:rsscontent tagitem:@"img"] tagitem:@"a"] tagitem:@"/a"];
        
        //image
        NSString *imageurl = nil;
        NSScanner *theScanner = [NSScanner scannerWithString:rsscontent];
        [theScanner scanUpToString:@"<img" intoString:nil];
        if (![theScanner isAtEnd]) {
            [theScanner scanUpToString:@"src" intoString:nil];
            NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
            [theScanner scanUpToCharactersFromSet:charset intoString:nil];
            [theScanner scanCharactersFromSet:charset intoString:nil];
            [theScanner scanUpToCharactersFromSet:charset intoString:&imageurl];
            
            imageurl = [imageurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if ([imageurl rangeOfString:@"mf.gif"].location != NSNotFound || [imageurl rangeOfString:@"icon_smile.gif"].location != NSNotFound || [imageurl rangeOfString:@"sayyac"].location != NSNotFound || [imageurl rangeOfString:@"feedburner"].location != NSNotFound) {
                imageurl = @"false";
            }
        } else {
            // resim yoksa
            imageurl = @"false";
        }
        
        // remove image tag / a tag
        NSString *tsummary = [self imagenHtml:[self imagenHtml:[self imagenHtml:rsscontent tagitem:@"img"] tagitem:@"a"] tagitem:@"/a"];
        
        
        //tsummary = [tsummary convertFromEncoding:@"ISO-8859-9"];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        // tarih bos ise
        NSString *ntempdate = [df stringFromDate:item.date];
        if(ntempdate == NULL || ntempdate == nil) {
            ntempdate = [df stringFromDate:nDate];
        }
        
        NSString *tempenc = @"no";
        if (item.enclosures) {
            for (NSDictionary *dict in item.enclosures){
                if ([(NSString *)[dict objectForKey:@"type"] isEqualToString:@"thumbNail"] || [(NSString *)[dict objectForKey:@"type"] isEqualToString:@"image/jpeg"]) {
                    imageurl = [dict objectForKey:@"url"];
                    tempenc = @"yes";
                }
            }
        }

        if (item.thumbnail && [tempenc  isEqual: @"no"]) {
            imageurl = item.thumbnail;
        }

        if(item.url) {
            imageurl = item.url;
        }
        if(item.link && item.title) { // link var ise ekle
            BOOL success;
            success = [database executeUpdate:@"INSERT INTO news (ntitle,nstriptitle,ndesc,ndate,nlink,newsubid,newname,newsubname,ninsertdate,nimage,nfav) VALUES (?,?,?,?,?,?,?,?,?,?,?);",
                                        item.title,
                                        [self slug:item.title],
                                        tsummary,
                                        ntempdate,
                                        item.link,
                                        [self.ndata objectForKey:@"id"],
                                        [self.ndata objectForKey:@"name"],
                                        [self.ndata objectForKey:@"subname"],
                                        [nDate description],
                                        imageurl,
                                        [self.ndata objectForKey:@"favico"],
                                    nil];
            if (success) {
                insertnumber++;
            }
        } else {
            NSLog(@"title veya link yok");
        }

    }

    
    [database close];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    self.title = [self.ndata objectForKey:@"name"];
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {

    if (parsedItems.count == 0) {
        self.title = NSLocalizedString(@"FailedInternet",nil);; // Show failed message in title
        
        HUD.labelText = NSLocalizedString(@"Failed",nil);
        
        [HUD hide:YES afterDelay:1.5];
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unsuccessful",nil)
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self updateTableWithParsedItems];
}


- (void)updateTableWithParsedItems {
    tableData = [self getNews:[[self.ndata objectForKey:@"id"] intValue]];
    self.nlistTable.userInteractionEnabled = YES;
    if(insertnumber > 0) {
        HUD.labelText = NSLocalizedString(@"ListUpdating",nil);
        [HUD show:YES];

        [self.nlistTable beginUpdates];
        [self.nlistTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.nlistTable endUpdates];
        
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] init];
        HUD.mode = MBProgressHUDModeCustomView;
        
        HUD.labelText = [NSString stringWithFormat:NSLocalizedString(@"AddNews", @""), [NSNumber numberWithInteger:insertnumber]];
    }
    
    [HUD hide:YES afterDelay:1.0]; // progress bar remove

}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GundemNews *newsData = tableData[indexPath.row]; //[tableData objectForKey:[NSNumber numberWithInt:indexPath.row]];

    static NSString *CellIdentifier = @"NListCell";
    UITableViewCell *cellData = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cellData == nil) {
        cellData = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cellData.selectionStyle = UITableViewCellSelectionStyleGray;
    
    // this is where you set your color view
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor colorWithRed:222/255.0f green:222/255.0f blue:222/255.0f alpha:0.5f];
    cellData.selectedBackgroundView =  customColorView;
    
    
    UIImageView *cImageView = (UIImageView *)[cellData viewWithTag:100];
    cImageView.image = [UIImage imageNamed:[self.ndata objectForKey:@"favico"]];
    
    FMLabel *cNameLabelTag = (FMLabel *)[cellData viewWithTag:101];
    cNameLabelTag.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:10.0];
    cNameLabelTag.layer.cornerRadius = 4;
    
    cNameLabelTag.textColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    cNameLabelTag.text = [NSString stringWithFormat:@"%@/%@", newsData.channelName, newsData.channelCategory];

    cNameLabelTag.textAlignment = NSTextAlignmentCenter;

    CGSize size = [cNameLabelTag.text sizeWithFont:cNameLabelTag.font constrainedToSize:CGSizeMake(150, 9999)];
    
    [cNameLabelTag setBackgroundColor:[UIColor colorWithRed:216/255.0f green:216/255.0f blue:192/255.0f alpha:1.0f]];
    size.width += 10;
    //size.height += 5;
    cNameLabelTag.width = size.width;
    cNameLabelTag.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UILabel *cNameLabelDate = (UILabel *)[cellData viewWithTag:102];
    
    cNameLabelDate.text = newsData.dateString;
    cNameLabelDate.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:11.0];
    cNameLabelDate.numberOfLines = 0;
    cNameLabelDate.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    cNameLabelDate.highlightedTextColor = [UIColor blackColor];

    
    UILabel *cNameLabel = (UILabel *)[cellData viewWithTag:103];
    
    cNameLabel.text = newsData.title;
    cNameLabel.font = [UIFont fontWithName:[params valueForKey:@"APPBOLDFONTNAME"] size:13.0];
    cNameLabel.numberOfLines = 0;
    cNameLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    cNameLabel.highlightedTextColor = [UIColor blackColor];
    
    if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"LEFT"]) {
        cNameLabel.textAlignment = NSTextAlignmentLeft;
    } else if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"RIGHT"]) {
        cNameLabel.textAlignment = NSTextAlignmentRight;
    }
    
    UILabel *cNameDesc = (UILabel *)[cellData viewWithTag:104];
    cNameDesc.highlightedTextColor = [UIColor blackColor];
    
    NSString *tempdesc = @"";
    if(newsData.content && ![newsData.content isEqual:[NSNull null]]) {
        tempdesc = [newsData.content stringByConvertingHTMLToPlainText];
    }
    //NSLog(@"newsdata %@",newsData);
    //NSString *tempdesc = newsData.content ? [newsData.content stringByConvertingHTMLToPlainText] : @" ";
    tempdesc = [tempdesc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cNameDesc.text = tempdesc;
    cNameDesc.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:12.0];
    cNameDesc.numberOfLines = 0;
    cNameDesc.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    
    if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"LEFT"]) {
        cNameDesc.textAlignment = NSTextAlignmentLeft;
    } else if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"RIGHT"]) {
        cNameDesc.textAlignment = NSTextAlignmentRight;
    }
    
    UIImageView *cNewsImageView = (UIImageView *)[cellData viewWithTag:105];
    cNewsImageView.layer.cornerRadius = 4.0f;

    if (self.firstCellLabelWidth == 0) {
        self.firstCellLabelWidth = cNameLabel.frame.size.width;
        self.firstCellDescWidth = cNameDesc.frame.size.width;
    }
    
    if(newsData.imageUrl && ![newsData.imageUrl isEqualToString:@"false"] && newsData.imageUrl != nil && self.newsImageState == NO) {

        [cNewsImageView setAlpha:1.0f];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             CGRect labelFrame = cNameLabel.frame;
                             labelFrame.size.width = self.firstCellLabelWidth-(cNewsImageView.frame.size.width+5);
                             cNameLabel.frame = labelFrame;
                             
                             CGRect descFrame = cNameDesc.frame;
                             descFrame.size.width = self.firstCellDescWidth-(cNewsImageView.frame.size.width+5);
                             cNameDesc.frame = descFrame;
                         }
                         completion:^(BOOL finished){

                         }];
        
        [cNewsImageView setHidden:NO];
        cNewsImageView.imageURL = nil;
        cNewsImageView.clipsToBounds = YES;
        cNewsImageView.netImage.URL = [NSURL URLWithString:newsData.imageUrl];
        cNewsImageView.netImage.crossfadeImages = YES;
        cNewsImageView.netImage.cacheDecodedResults = YES;

    } else {
        [cNewsImageView setAlpha:1.0f];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [cNewsImageView setAlpha:0.0f];
                             CGRect labelFrame = cNameLabel.frame;
                             labelFrame.size.width = self.firstCellLabelWidth;
                             cNameLabel.frame = labelFrame;
                             
                             CGRect descFrame = cNameDesc.frame;
                             descFrame.size.width = self.firstCellDescWidth;
                             cNameDesc.frame = descFrame;
                         }
                         completion:^(BOOL finished){
                             [cNewsImageView setHidden:YES];
                             cNewsImageView.imageURL = nil;
                         }];
        
    }
    
    return cellData;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NDViewController *NDViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NDViewController"];
	NDViewController.delegate = self;
    NDViewController.currentNews = tableData[indexPath.row];
    [self.navigationController pushViewController:NDViewController animated:YES];
}

- (BOOL)nextNewsAvailableForNews:(GundemNews*)newsData {
	NSUInteger newsIndex = [tableData indexOfObject:newsData];
	if (tableData.count > newsIndex + 1)
		return YES;
	return NO;
}
- (BOOL)previousNewsAvailableForNews:(GundemNews*)newsData {
	NSUInteger newsIndex = [tableData indexOfObject:newsData];
	if (newsIndex > 0)
		return YES;
	return NO;
}

- (GundemNews*)nextNewsForNews:(GundemNews*)newsData {
	NSUInteger newsIndex = [tableData indexOfObject:newsData];
	if (tableData.count > newsIndex + 1) {
		return tableData[newsIndex + 1];
	}
	return nil;
}
- (GundemNews*)previousNewsForNews:(GundemNews*)newsData {
	NSUInteger newsIndex = [tableData indexOfObject:newsData];
	if (newsIndex > 0) {
		return tableData[newsIndex - 1];
	}
	return nil;
}

- (void)setUpDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"newsdata.sqlite"];
    database = [FMDatabase databaseWithPath:dbPath];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(ftimer) {
        [ftimer invalidate];
    }
    if (HUD) {
        [HUD hide:YES];
    }
    [self.nlistTable deselectRowAtIndexPath:[self.nlistTable indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hideNewsImage = [defaults boolForKey:@"hideNewsImage"];
    
    self.newsImageState = hideNewsImage;
    
    //// if one page ////
    NSDictionary *tempconfig = [params valueForKey:@"ONEPAGESETTINGS"];
    NSInteger oneRSSPage = [[tempconfig valueForKey:@"OneRSSPage"] intValue];
    
    if (oneRSSPage == 1) {
        [self setUpDatabase];
        
        [database open];
        
        [database executeUpdate:@"CREATE TABLE IF NOT EXISTS \"news\" (\"id\" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \"ntitle\" VARCHAR, \"nstriptitle\" VARCHAR, \"ndesc\" TEXT, \"ndate\" TEXT, \"nlink\" VARCHAR, \"newid\" INTEGER, \"newsubid\" INTEGER, \"newname\" VARCHAR, \"newsubname\" VARCHAR, \"ninsertdate\" TIMESTAMP, \"nimage\" TEXT DEFAULT NULL, \"nfav\" TEXT,UNIQUE (nstriptitle, newsubid));"];
        
        [database executeUpdate:@"CREATE TABLE IF NOT EXISTS \"subcategory\" (\"id\" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \"name\" VARCHAR UNIQUE, \"subname\" VARCHAR, \"favico\" VARCHAR, \"rssurl\" TEXT,\"row\" INTEGER, \"state\" INTEGER DEFAULT 0);"];
        
        NSDictionary *item0 = [tempconfig objectForKey:@"Item0"];
        self.ndata = [[NSMutableDictionary alloc] init];
        [self.ndata setObject:@"1" forKey:@"id"];
        [self.ndata setObject:[item0 valueForKey:@"Name"] forKey:@"name"];
        [self.ndata setObject:[item0 valueForKey:@"Url"] forKey:@"rssurl"];
        [self.ndata setObject:[item0 valueForKey:@"IconName"] forKey:@"favico"];
        [self.ndata setObject:[item0 valueForKey:@"SubName"] forKey:@"subname"];
        [self.ndata setObject:@"1" forKey:@"row"];
        NSLog(@"  %@",self.ndata);
        [self setUpInfoButton];
    } else {
        [self setUpChangeImageButton];
        [self setUpImageBackButton];
    }

    
    //self.navigationItem.title = self.ntitle;
    self.title = [self.ndata objectForKey:@"name"];
    [self setUpDatabase];

    tableData = [self getNews:[[self.ndata objectForKey:@"id"] intValue]];
    NSLog(@"url :%@ ",[self.ndata objectForKey:@"rssurl"]);
    NSURL *feedURL = [NSURL URLWithString:[self.ndata objectForKey:@"rssurl"]];
    //NSURL *feedURL = [NSURL URLWithString:@"http://rss.hurriyet.com.tr/rss.aspx?sectionId=1"];
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    feedParser.connectionType = ConnectionTypeSynchronously;
    
	// Do any additional setup after loading the view.
    
    self.nrefresh = [[UIRefreshControl alloc] init];
    self.nrefresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Update",nil)];
    [self.nrefresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = self.nrefresh;
    
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];

    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.userInteractionEnabled = NO;
    HUD.delegate = self;
    
    if(tableData.count <= 0) {

        HUD.labelText = NSLocalizedString(@"ListUpdating",nil);

        [HUD show:YES];
        [self refresh];
    } else {
        ftimer = [NSTimer scheduledTimerWithTimeInterval: 3.0 target:self selector:@selector(startFeedParse:) userInfo:nil repeats: NO];
        
    }

    [self addSoundForUIControls];
}

- (void)addSoundForUIControls {
    NSString *soundAFilePath = [NSBundle.mainBundle pathForResource:@"tap-mellow" ofType:@"aif"];
    [self.refreshControl addSoundWithContentsOfFile:soundAFilePath forControlEvents:UIControlEventAllEvents];
}

-(void)refreshView:(UIRefreshControl *)nrefresh {
    [self refresh];
    nrefresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ListUpdating",nil)];
    
    // custom refresh logic would be placed here...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    
    NSString *lastUpdated = [NSString stringWithFormat:NSLocalizedString(@"LastUpdate", @""), [formatter stringFromDate:[NSDate date]]];
    
    nrefresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    [nrefresh endRefreshing];
}

-(void) startFeedParse: (NSTimer *) theTimer
{
    // Parse
    NSLog(@"start");
    //[feedParser parse];
    
    [feedParser performSelectorOnMainThread:@selector(parse) withObject:nil waitUntilDone:NO];
    
	//[feedParser parse];
}

-(void) startBackgroundFeedParse
{
    // Parse
    [feedParser performSelectorOnMainThread:@selector(parse) withObject:nil waitUntilDone:NO];
	//[feedParser parse];
}

// databaseden haberleri cek
-(NSMutableArray *)getNews: (NSInteger)nnid
{
    [database open];
    FMResultSet *results = [database executeQuery:@"SELECT * FROM news WHERE newsubid = ? order by ndate desc limit 0,50",[NSNumber numberWithInt:nnid]];
    
    NSMutableArray *tempdata2 = [NSMutableArray new];
    while ([results next]) {
		GundemNews* newsData = [GundemNews newsWithDBResultSet:results];
        [tempdata2 addObject:newsData];
    }
    
    return tempdata2;
}

-(NSString *)slug: (NSString *)stext
{
    stext = [stext stringByReplacingOccurrencesOfString:@"ğ" withString:@"g"];
    stext = [stext stringByReplacingOccurrencesOfString:@"ü" withString:@"u"];
    stext = [stext stringByReplacingOccurrencesOfString:@"ş" withString:@"s"];
    stext = [stext stringByReplacingOccurrencesOfString:@"ç" withString:@"c"];
    stext = [stext stringByReplacingOccurrencesOfString:@"ö" withString:@"o"];
    stext = [stext stringByReplacingOccurrencesOfString:@"ı" withString:@"i"];
    stext = [stext stringByReplacingOccurrencesOfString:@"â" withString:@"a"];
    stext = [stext stringByReplacingOccurrencesOfString:@"û" withString:@"u"];
    stext = [stext stringByReplacingOccurrencesOfString:@"Ğ" withString:@"g"];
    stext = [stext stringByReplacingOccurrencesOfString:@"Ü" withString:@"u"];
    stext = [stext stringByReplacingOccurrencesOfString:@"Ş" withString:@"s"];
    stext = [stext stringByReplacingOccurrencesOfString:@"Ç" withString:@"c"];
    stext = [stext stringByReplacingOccurrencesOfString:@"Ö" withString:@"o"];
    stext = [stext stringByReplacingOccurrencesOfString:@"İ" withString:@"i"];
    stext = [stext stringByReplacingOccurrencesOfString:@"î" withString:@"i"];
    stext = [stext stringByReplacingOccurrencesOfString:@"?" withString:@"-"];
    stext = [stext stringByReplacingOccurrencesOfString:@"!" withString:@"-"];
    stext = [stext stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    stext = [stext stringByReplacingOccurrencesOfString:@"," withString:@""];
    stext = [stext stringByReplacingOccurrencesOfString:@"(" withString:@""];
    stext = [stext stringByReplacingOccurrencesOfString:@")" withString:@""];
    stext = [stext stringByReplacingOccurrencesOfString:@"'" withString:@""];
    stext = [stext stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    stext = [stext stringByReplacingOccurrencesOfString:@"/" withString:@""];
    stext = [stext stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    
    stext = [stext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    stext = [stext stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    return stext;
}

- (void)setUpInfoButton
{
    
    NSString *leftbt = @"edit.png";
    NSString *rightbt = @"info.png";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        leftbt = @"edit7.png";
        rightbt = @"info7.png";
    }
    
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 22)];
    [infoButton setBackgroundImage:[UIImage imageNamed:rightbt] forState:UIControlStateNormal];
    UIBarButtonItem *barinfoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(infoModal) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = barinfoButtonItem;
    
}


- (void)infoModal
{
    NInfoViewController *NInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"NInfoViewController"];
    NInfoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NInfoController.modalTransitionStyle = UIModalPresentationFullScreen;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController presentViewController:NInfoController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
