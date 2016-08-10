//
//  NSourceViewController.m
//  NewsApp
//
//  Created by yvzyldrm on 9/12/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import "NSourceViewController.h"

@interface NSourceViewController ()

@end

@implementation NSourceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    SourceNavigation.layer.zPosition = 10;
    
    nsourcetable.frame = CGRectMake(0, SourceNavigation.frame.size.height+20, nsourcetable.frame.size.width, nsourcetable.frame.size.height-20);

    SourceNavigation.translucent = NO;
    
    
    SourceNavigation.topItem.title = NSLocalizedString(@"SourceTitle",nil);
    
    SourceNavigation.tintColor = [UIColor colorWithWhite:0 alpha:.9];
    
    
    
    UIColor *tcolor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    UIFont *customfont = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:16.0];
    
    SourceNavigation.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          tcolor, NSForegroundColorAttributeName,
                                          customfont, NSFontAttributeName,
                                          nil];
    [SourceNavigation setNeedsLayout];
    [SourceNavigation setTitleVerticalPositionAdjustment:1.0 forBarMetrics:UIBarMetricsDefault];

    [self setUpImageBackButton];
    [self setUpDatabase];

    [database open];
    [self nfetchDatabase];
    [database close];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectcolor"];
    UIColor *tempcolor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    [SourceNavigation setBackgroundColor:tempcolor];
    statusColor.backgroundColor = tempcolor;

    
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        [SourceNavigation setTintColor:tempcolor];
        SourceNavigation.barTintColor = tempcolor;
        statusColor.tintColor = tempcolor;
    }
    
    [SourceNavigation setNeedsDisplay];
}

-(void) nfetchDatabase {
    FMResultSet *results = [database executeQuery:@"SELECT * FROM subcategory ORDER BY name ASC"];
    
    NSMutableArray *tempdata = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempdic2 = [[NSMutableDictionary alloc] init];
    
    while([results next])
    {
        NSMutableDictionary *tempdic = [[NSMutableDictionary alloc] init];
        
        //[tempdata addObject:[NSNumber numberWithInt:[results intForColumn:@"id"]]];
        
        [tempdata addObject:[results stringForColumn:@"name"]];
        [tempdic setObject:[NSNumber numberWithInt:[results intForColumn:@"id"]] forKey:@"id"];
        [tempdic setObject:[results stringForColumn:@"name"] forKey:@"name"];
        [tempdic setObject:[results stringForColumn:@"favico"] forKey:@"favico"];
        
        [tempdic2 setObject:tempdic forKey:[results stringForColumn:@"name"]];
        
    }
    
    tableData = tempdata;
    ndata = tempdic2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark){
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *nLabel = (UILabel*)[cell.contentView viewWithTag:100];
        
        [self removeItem:nLabel.text];
    }else{
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *nLabel = (UILabel*)[cell.contentView viewWithTag:100];

        [self addItem:nLabel.text];
    }
}

-(void)removeItem: (NSString*) title {
    [database open];
    [database executeUpdate:@"UPDATE subcategory SET state='0' WHERE name=? ;", title,nil];
    [database close];
}

-(void)addItem: (NSString*) title {
    [database open];
    [database executeUpdate:@"UPDATE subcategory SET state='1',row=? WHERE name=? ;", [NSNumber numberWithInteger:[self lastItem]+1],title,nil];
    [database close];
}

-(NSInteger)lastItem {
    [database open];
    FMResultSet *res = [database executeQuery:@"SELECT MAX(row) as nrow FROM subcategory",nil];
    NSInteger nrow = -1;
    while([res next]) {
        nrow = [res intForColumn:@"nrow"];
    }
    return nrow;
}

-(NSInteger)checkItem: (NSString*) title {
    [database open];
    FMResultSet *res = [database executeQuery:@"SELECT * FROM subcategory where name=? ORDER BY name ASC",title,nil];
    NSInteger state = -1;
    while([res next])
    {
        state = [res intForColumn:@"state"];
    }
    return state;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"NSourceCell2";
    UITableViewCell *cellData = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cellData == nil) {
        cellData = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if ([self checkItem:[tableData objectAtIndex:indexPath.row]] == 1) {
        cellData.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cellData.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UILabel *cNameLabel = (UILabel *)[cellData viewWithTag:100];
    cNameLabel.text = [tableData objectAtIndex:indexPath.row];
    cNameLabel.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:16.0f];
    cNameLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    
    if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"LEFT"]) {
        cNameLabel.textAlignment = NSTextAlignmentLeft;
    } else if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"RIGHT"]) {
        cNameLabel.textAlignment = NSTextAlignmentRight;
    }
    
    UIImageView *cFavImage = (UIImageView *)[cellData viewWithTag:102];
    NSString *tempfav = [[ndata objectForKey:[tableData objectAtIndex:indexPath.row]] objectForKey:@"favico"];
    cFavImage.image = [UIImage imageNamed:tempfav];
    
    //cellData.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cellData;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)setUpDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"newsdata.sqlite"];
    database = [FMDatabase databaseWithPath:dbPath];
}

- (void)setUpImageBackButton
{
    //UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(SourceNavigation.frame.size.width-32, 10, 23, 23)];
    //[backButton setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    //[backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    //backButton.tag = 22;
    //[SourceNavigation addSubview:backButton];
    
    UIImage *tempimage = [UIImage imageNamed:@"close.png"];
    //tempimage = [UIImage imageWithData:UIImagePNGRepresentation(tempimage) scale:2];
    [backbutton setBackgroundImage:tempimage forState:UIControlStateNormal];
}

- (IBAction)popCurrentViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
