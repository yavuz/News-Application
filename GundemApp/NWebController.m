//
//  NWebController.m
//  NewsApp
//
//  Created by yvzyldrm on 8/27/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import "NWebController.h"

@interface NWebController ()

@end

@implementation NWebController
@synthesize nwebView;

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
    
    
    if ([[params valueForKey:@"ADMOBWEBVIEW"]intValue]) {
        CGPoint origin = CGPointMake(0.0,self.view.frame.size.height+40);
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
        bannerView_.adUnitID = [params valueForKey:@"ADMOBKEY"];
        bannerView_.rootViewController = self;
        bannerView_.delegate = self;
        bannerView_.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleTopMargin;
        [bannerView_ loadRequest:[GADRequest request]];
        
        bannerView_.frame = CGRectMake(0.0,
                                       self.view.frame.size.height -
                                       bannerView_.frame.size.height,
                                       self.view.frame.size.width,
                                       bannerView_.frame.size.height);
        
        [self.view addSubview:bannerView_];
        [UIView animateWithDuration:2.0f
                              delay:0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             CGRect myFrame = bannerView_.frame;
                             myFrame.origin = CGPointMake(0.0,self.view.frame.size.height-
                                                          CGSizeFromGADAdSize(kGADAdSizeBanner).height);
                             bannerView_.frame = myFrame;
                         }
                         completion:^(BOOL finished){
                         }
         ];
    }
}

- (IBAction)popCurrentViewController:(id)sender
{
    [super dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WebNavigation.layer.zPosition = 10;
    
    nwebView.frame = CGRectMake(0, WebNavigation.frame.size.height+20, nwebView.frame.size.width, nwebView.frame.size.height-20);
    
    [self setUpImageBackButton];
    NSURL *websiteUrl = [NSURL URLWithString:self.webLink];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    nwebView.dataDetectorTypes = UIDataDetectorTypeNone;
    nwebView.scalesPageToFit = YES;
    [nwebView loadRequest:urlRequest];
    
    WebNavigation.translucent = NO;
    WebNavigation.topItem.title = NSLocalizedString(@"Loading",nil);
    
    UIColor *tcolor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    UIFont *customfont = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:16.0];
    
    WebNavigation.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                              tcolor, NSForegroundColorAttributeName,
                                              customfont, NSFontAttributeName,
                                              nil];
    
    
    [WebNavigation setNeedsLayout];
    [WebNavigation setTitleVerticalPositionAdjustment:1.0 forBarMetrics:UIBarMetricsDefault];
    
}

-(void)viewWillAppear:(BOOL)animated {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectcolor"];
    UIColor *tempcolor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    [WebNavigation setBackgroundColor:tempcolor];
    statusColor.backgroundColor = tempcolor;

    
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        [WebNavigation setTintColor:tempcolor];
        WebNavigation.barTintColor = tempcolor;
        statusColor.tintColor = tempcolor;
    }
    
    
    [WebNavigation setNeedsDisplay];
}

-(void) setWebLink:(NSString *)webLink {
    _webLink = webLink;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    WebNavigation.topItem.title = NSLocalizedString(@"WebTitle",nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    //[self.nwebView loadHTMLString:@"<html></html>" baseURL:nil];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    //[[NSURLCache sharedURLCache] setDiskCapacity:0];
    //[[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

@end
