//
//  NInfoViewController.m
//  NewsApp
//
//  Created by yvzyldrm on 9/3/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import "NInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "EDColor.h"

@interface NInfoViewController ()

@end

@implementation NInfoViewController

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
    UIImage *tempimage = [UIImage imageNamed:@"close.png"];
    [backbutton setBackgroundImage:tempimage forState:UIControlStateNormal];

}

- (IBAction)popCurrentViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{

    [super viewDidLoad];

    InfoNavigation.topItem.title = NSLocalizedString(@"AppName",nil);
    InfoNavigation.tintColor = [UIColor colorWithWhite:0 alpha:.9];

    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            InfoNavigation.frame = CGRectMake(0, InfoNavigation.frame.origin.y-18, InfoNavigation.frame.size.width, InfoNavigation.frame.size.height);
        }
        InfoNavigation.layer.zPosition = 10;
    }
    
    InfoNavigation.translucent = NO;

    UIColor *tcolor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    UIFont *customfont = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:16.0];
    
    InfoNavigation.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         tcolor, NSForegroundColorAttributeName,
                                         customfont, NSFontAttributeName,
                                         nil];
    [InfoNavigation setNeedsLayout];
    [InfoNavigation setTitleVerticalPositionAdjustment:1.0 forBarMetrics:UIBarMetricsDefault];
    
    HUD = [[MBProgressHUD alloc] initWithView:nscrollView];
    [nscrollView addSubview:HUD];
    HUD.delegate = self;
    nscrollView.top = InfoNavigation.frame.size.height+20;
    
    
    NInfoDesc.text = NSLocalizedString(@"AppDesc",nil);
    
    [rateButton setTitle:NSLocalizedString(@"RateButton",nil) forState:UIControlStateNormal];
    [shareButton setTitle:NSLocalizedString(@"ShareButton",nil) forState:UIControlStateNormal];
    [cacheButton setTitle:NSLocalizedString(@"CleanCache",nil) forState:UIControlStateNormal];
    ncolorLabel.text = NSLocalizedString(@"SelectColor",nil);
    
    
    
    [self setUpImageBackButton];
    
}

-(void) viewDidLayoutSubviews {
    
    CGFloat lastTop = 0.0;
    CGFloat marginTop = 10.0;
    //npagetopview.top = lastTop+marginTop;
    
    NInfoDesc.top = lastTop+marginTop;
    
    NInfoDesc.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    NInfoDesc.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:14.0];
    
    CGSize size = [NInfoDesc.text sizeWithFont:NInfoDesc.font constrainedToSize:CGSizeMake(NInfoDesc.width, 99999)];
    //NInfoDesc.numberOfLines = 0;
    float currentVersion = 7.0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        NInfoDesc.height = size.height+40;
    } else {
        NInfoDesc.height = size.height+15;
    }

    lastTop = NInfoDesc.bottom;
    
    UIColor *bcolor = [UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0f];
    UIColor *tcolor = [UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f];
    UIColor *nbcolor = [UIColor colorWithRed:218/255.0f green:168/255.0f blue:92/255.0f alpha:1.0f];

    shareButton.top = lastTop+marginTop;
    
    // share button
    shareButton.buttonBackgroundColor = nbcolor;
    shareButton.buttonForegroundColor = [UIColor whiteColor];
    [shareButton setFlatTitle:NSLocalizedString(@"ShareButton",nil)];
    shareButton.layer.cornerRadius = 5;
    shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];

    
    lastTop = shareButton.bottom;

    // rate button
    rateButton.top = lastTop+marginTop;
    rateButton.buttonBackgroundColor = nbcolor;
    rateButton.buttonForegroundColor = [UIColor whiteColor];
    rateButton.layer.cornerRadius = 5;
    [rateButton setFlatTitle:NSLocalizedString(@"RateButton",nil)];
    rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
    lastTop = rateButton.bottom;
    
    // cachebutton
    cacheButton.top = lastTop+marginTop;
    cacheButton.buttonBackgroundColor = nbcolor;
    cacheButton.buttonForegroundColor = [UIColor whiteColor];
    cacheButton.layer.cornerRadius = 5;
    [cacheButton setFlatTitle:NSLocalizedString(@"CleanCache",nil)];
    cacheButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
    lastTop = cacheButton.bottom;
    
    ncolorline.top = lastTop+15.0f;
    ncolorline.layer.borderWidth = 1.0f;
    ncolorline.layer.borderColor = bcolor.CGColor;
    
    lastTop = ncolorline.bottom;
    
    ncolorLabel.top = lastTop+marginTop;
    ncolorLabel.font = [UIFont fontWithName:[params valueForKey:@"APPBOLDFONTNAME"] size:14.0];
    ncolorLabel.textColor = tcolor;
    
    if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"LEFT"]) {
        ncolorLabel.textAlignment = NSTextAlignmentLeft;
    } else if([[params valueForKey:@"APPFONTALIGN"] isEqualToString:@"RIGHT"]) {
        ncolorLabel.textAlignment = NSTextAlignmentRight;
    }
    
    lastTop = ncolorLabel.bottom;
    
    NSArray *colorArray= [params valueForKey:@"OPTIONALCOLORS"];
    
    color1.top = lastTop+marginTop;
    color1.buttonBackgroundColor = [UIColor colorWithHexString:colorArray[0]];
    color1.layer.cornerRadius = 5;
    
    color2.top = lastTop+marginTop;
    color2.buttonBackgroundColor = [UIColor colorWithHexString:colorArray[1]];
    color2.layer.cornerRadius = 5;
    
    color3.top = lastTop+marginTop;
    color3.buttonBackgroundColor = [UIColor colorWithHexString:colorArray[2]];
    color3.layer.cornerRadius = 5;
    
    color4.top = lastTop+marginTop;
    color4.buttonBackgroundColor = [UIColor colorWithHexString:colorArray[3]];
    color4.layer.cornerRadius = 5;
    
    color5.top = lastTop+marginTop;
    color5.buttonBackgroundColor = [UIColor colorWithHexString:colorArray[4]];
    color5.layer.cornerRadius = 5;

    
    lastTop = color1.bottom;
    
    nline.top = lastTop+15.0f;
    nline.layer.borderWidth = 1.0f;
    nline.layer.borderColor = bcolor.CGColor;
    
    lastTop = nline.bottom;
    
    yappsLabel.top = lastTop+40;
    //[yappsLabel setImage:[UIImage imageNamed:@"infologo.png"]];
    lastTop = yappsLabel.bottom+130;

    [rateButton addTarget:self action:@selector(openRate:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton addTarget:self action:@selector(openShare:) forControlEvents:UIControlEventTouchUpInside];
    [cacheButton addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];
    
    [color1 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];
    [color2 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];
    [color3 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];
    [color4 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];
    [color5 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];

    [(UIScrollView*)nscrollView setContentSize:CGSizeMake(nscrollView.frame.size.width, lastTop)];
}

- (IBAction)clearCache: (id) sender {
    HUD.labelText = NSLocalizedString(@"Cleaning",nil);//
    [HUD show:YES];
    [self setUpDatabase];
    [database open];
    [database executeUpdate:@"DELETE FROM news"];
    [database close];
    
    [HUD hide:YES afterDelay:1.0]; // progress bar remove
}

- (void)openShare: (id) sender
{
    
    UIImage *anImage = [UIImage imageNamed:@"sharepic.png"];
    NSURL *nlink = [NSURL URLWithString:[params valueForKey:@"ITUNESLINK"]];
    
    NSString *temptext = NSLocalizedString(@"InfoShareText",nil);;
    NSArray *Items   = [NSMutableArray arrayWithObjects:
                               temptext,
                               anImage, nlink, nil];
    
    ActivityView =
    [[UIActivityViewController alloc]
     initWithActivityItems:Items applicationActivities:nil];
    
    
    if ( [ActivityView respondsToSelector:@selector(popoverPresentationController)] ) { // iOS8
        ActivityView.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:ActivityView animated:YES completion:nil];
    
    

}


- (IBAction)openRate: (id) sender {
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"noads"];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"noads"];
    NSString *urlString= [params valueForKey:@"ITUNESLINK"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


- (void)setUpDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"newsdata.sqlite"];
    database = [FMDatabase databaseWithPath:dbPath];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)changeColor:(id)sender {
    UIColor *tempcolor = [UIColor colorWithRed:40/255.0f green:48/255.0f blue:55/255.0f alpha:1.0f];
    
    NSArray *colorArray= [params valueForKey:@"OPTIONALCOLORS"];
    if([sender tag] == 1) {
        tempcolor = [UIColor colorWithHexString:colorArray[0]];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:tempcolor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectcolor"];
    } else if([sender tag] == 2) {
        tempcolor = [UIColor colorWithHexString:colorArray[1]];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:tempcolor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectcolor"];
    } else if([sender tag] == 3) {
        tempcolor = [UIColor colorWithHexString:colorArray[2]];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:tempcolor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectcolor"];
    } else if([sender tag] == 4) {
        tempcolor = [UIColor colorWithHexString:colorArray[3]];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:tempcolor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectcolor"];
    } else if([sender tag] == 5) {
        tempcolor = [UIColor colorWithHexString:colorArray[4]];
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:tempcolor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"selectcolor"];
    }
    NSLog(@"TEMPCOLOR: %@",tempcolor);
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [InfoNavigation setBackgroundColor:tempcolor];
    statusColor.backgroundColor = tempcolor;
    
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        [InfoNavigation setTintColor:tempcolor];
        InfoNavigation.barTintColor = tempcolor;
        statusColor.tintColor = tempcolor;
    }
    
    [InfoNavigation setNeedsDisplay];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectcolor"];
    UIColor *tempcolor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    [InfoNavigation setBackgroundColor:tempcolor];
    statusColor.backgroundColor = tempcolor;
    
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        [InfoNavigation setTintColor:tempcolor];
        InfoNavigation.barTintColor = tempcolor;
        statusColor.tintColor = tempcolor;
    }
    
    [InfoNavigation setNeedsDisplay];
}

@end
