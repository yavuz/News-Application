//
//  ViewController.m
//  NewsApp
//
//  Created by yvzyldrm on 8/22/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import "ViewController.h"
#import "NListController.h"
#import "NInfoViewController.h"
#import "NSourceViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize ndata;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = NSLocalizedString(@"ViewTitle",nil);

    currentVersion = 7.0;
    
    // 2 gun onceyi al sil
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EET"]];
    NSDate* now = [NSDate date];
    int daysToAdd = 2;
    NSDate *newDate1 = [now dateByAddingTimeInterval:-60*60*24*daysToAdd];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *tempdate = [df stringFromDate:newDate1];

    [self setUpInfoButton];
    [self setUpDatabase];
    
    [database open];

    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS \"news\" (\"id\" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \"ntitle\" VARCHAR, \"nstriptitle\" VARCHAR, \"ndesc\" TEXT, \"ndate\" TEXT, \"nlink\" VARCHAR, \"newid\" INTEGER, \"newsubid\" INTEGER, \"newname\" VARCHAR, \"newsubname\" VARCHAR, \"ninsertdate\" TIMESTAMP, \"nimage\" TEXT DEFAULT NULL, \"nfav\" TEXT,UNIQUE (nstriptitle, newsubid));"];
    
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS \"subcategory\" (\"id\" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \"name\" VARCHAR UNIQUE, \"subname\" VARCHAR, \"favico\" VARCHAR, \"rssurl\" TEXT,\"row\" INTEGER, \"state\" INTEGER DEFAULT 0);"];

    
    NSDictionary *mainDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewsSources" ofType:@"plist"]];
    
    //---enumerate through the dictionary objects
    NSEnumerator *enumerator = [mainDictionary objectEnumerator];
    id value;
    
    while ((value = [enumerator nextObject])) {
        [database executeUpdate:@"INSERT INTO `subcategory` (`name`, `subname`, `favico`, `rssurl`,`state`,`row`) VALUES (?,?,?,?,?,?)",[value valueForKey:@"Name"],[value valueForKey:@"SubName"],[value valueForKey:@"IconName"],[value valueForKey:@"Url"],[value valueForKey:@"MainPageView"],[value valueForKey:@"MainPageOrder"]];
        
        [database executeUpdate:@"UPDATE `subcategory` SET rssurl=?,subname=? WHERE name=?",[value valueForKey:@"Url"],[value valueForKey:@"SubName"],[value valueForKey:@"Name"]];
    }
    
    
    [database executeUpdate:@"DELETE FROM news WHERE ndate <= ? ;",tempdate]; // before two days news delete
    
    [self nfetchDatabase];

    [database close];

}


-(void) viewWillAppear:(BOOL)animated {
    [database open];
    [self nfetchDatabase];
    [database close];
    [self reloadnTable];
}

-(void) reloadnTable {
    [nTableView beginUpdates];
    [nTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [nTableView endUpdates];
}

-(void) nfetchDatabase {
    FMResultSet *results = [database executeQuery:@"SELECT * FROM subcategory WHERE state=1 ORDER BY row ASC"];
    
    NSMutableArray *tempdata = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempdic2 = [[NSMutableDictionary alloc] init];
    
    while([results next])
    {
        NSMutableDictionary *tempdic = [[NSMutableDictionary alloc] init];
        
        [tempdata addObject:[results stringForColumn:@"name"]];
        [tempdic setObject:[NSNumber numberWithInt:[results intForColumn:@"id"]] forKey:@"id"];
        [tempdic setObject:[results stringForColumn:@"name"] forKey:@"name"];
        [tempdic setObject:[results stringForColumn:@"favico"] forKey:@"favico"];
        [tempdic setObject:[results stringForColumn:@"subname"] forKey:@"subname"];
        [tempdic setObject:[results stringForColumn:@"rssurl"] forKey:@"rssurl"];
        [tempdic setObject:[results stringForColumn:@"row"] forKey:@"row"];
        
        [tempdic2 setObject:tempdic forKey:[results stringForColumn:@"name"]];
        
    }
    
    tableData = tempdata;
    self.ndata = tempdic2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [tableData objectAtIndex:sourceIndexPath.row];
    [tableData removeObjectAtIndex:sourceIndexPath.row];
    [tableData insertObject:stringToMove atIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *nLabel = (UILabel*)[cell.contentView viewWithTag:100];
        
        // tableview remove
        [tableData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [database open];
        [database executeUpdate:@"UPDATE subcategory SET state = 0 WHERE name=? ;", nLabel.text ,nil];
        [database close];
    }
}


- (void) EditTable{
    if(self.editing)
    {
        [self setUpInfoButton];
        [super setEditing:NO animated:YES];
        [nTableView setEditing:NO animated:YES];
        
        NSInteger nrow = 1;
        [database open];
        [database executeUpdate:@"UPDATE subcategory SET row=0;",nil];  // reset rows
        for (NSString *tdata in tableData){
            [database executeUpdate:@"UPDATE subcategory SET state='1',row=? WHERE name=? ;", [NSNumber numberWithInteger:nrow] ,tdata,nil];
            nrow++;
        }
        
        [self nfetchDatabase];
        [database close];
        [self reloadnTable];
    } else {
        [self setUpAddButton];
        [super setEditing:YES animated:YES];
        [nTableView setEditing:YES animated:YES];
        [self reloadnTable];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NSourceCell";
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
    
    UIImageView *cImageView = (UIImageView *)[cellData viewWithTag:101];
    cImageView.image = [UIImage imageNamed:@"arrowmain.png"];
    if(self.editing) {
        [cImageView setHidden:YES];
    } else {
        [cImageView setHidden:NO];
    }
    
    UILabel *cNameLabel = (UILabel *)[cellData viewWithTag:100];
    cNameLabel.text = [tableData objectAtIndex:indexPath.row];
    cNameLabel.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:16.0f];
    cNameLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    cNameLabel.highlightedTextColor = [UIColor blackColor];
    if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"LEFT"]) {
        cNameLabel.textAlignment = NSTextAlignmentLeft;
    } else if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"RIGHT"]) {
        cNameLabel.textAlignment = NSTextAlignmentRight;
    }
    
    UIImageView *cFavImage = (UIImageView *)[cellData viewWithTag:102];
    NSString *tempfav = [[self.ndata objectForKey:[tableData objectAtIndex:indexPath.row]] objectForKey:@"favico"];
    cFavImage.image = [UIImage imageNamed:tempfav];
    
    return cellData;
}

-(void) openSourceList {
    NSourceViewController *NSourceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NSourceViewController"];
    NSourceViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController presentViewController:NSourceViewController animated:YES completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editing){
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cellData = [tableView cellForRowAtIndexPath:indexPath];
        
    UILabel *label = (UILabel*)[cellData viewWithTag:100];
    NSString *selectTitle = label.text;
    
    NListController *NListController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsListController"];
    NListController.ndata = [self.ndata objectForKey:selectTitle];
        
    [self.navigationController pushViewController:NListController animated:YES];
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete",nil);;
}

-(void)setUpAddButton
{
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 21)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        [infoButton setBackgroundImage:[UIImage imageNamed:@"add7.png"] forState:UIControlStateNormal];
    } else {
        [infoButton setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    }
    
    
    UIBarButtonItem *barinfoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(openSourceList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = barinfoButtonItem;


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
    
    if ([[params valueForKey:@"SOURCECUSTOMIZE"] intValue]) {
        UIButton *sourcesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [sourcesButton setBackgroundImage:[UIImage imageNamed:leftbt] forState:UIControlStateNormal];
        
        UIBarButtonItem *barsourcesButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sourcesButton];
        [sourcesButton addTarget:self action:@selector(EditTable) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = barsourcesButtonItem;
    }

}


- (void)infoModal
{
    NInfoViewController *NInfoController = [self.storyboard instantiateViewControllerWithIdentifier:@"NInfoViewController"];
    NInfoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NInfoController.modalTransitionStyle = UIModalPresentationFullScreen;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController presentViewController:NInfoController animated:YES completion:nil];
}


- (void)setUpDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"newsdata.sqlite"];
    database = [FMDatabase databaseWithPath:dbPath];
}

@end