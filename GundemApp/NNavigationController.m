//
//  NNavigationController.m
//  NewsApp
//
//  Created by yvzyldrm on 8/24/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import "NNavigationController.h"

@interface NNavigationController ()

@end

@implementation NNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //// if one page ////
    NSDictionary *tempconfig = [params valueForKey:@"ONEPAGESETTINGS"];
    NSInteger oneRSSPage = [[tempconfig valueForKey:@"OneRSSPage"] intValue];
    if (oneRSSPage==1) {
        ViewController *NListController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsListController"];
        self.viewControllers = [NSArray arrayWithObject:NListController];
        NSLog(@"yes kardes");
        self.navigationItem.hidesBackButton = NO;
    }


    for (UIView* aView in self.view.subviews) {
		if (![aView isKindOfClass:UINavigationBar.class]) {
			transitionView = aView;
			break;
		}
	}
    
    UIColor *tcolor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    UIFont *customfont = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:16.0];
    
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                tcolor, NSForegroundColorAttributeName,
                                customfont, NSFontAttributeName,
                                nil];

    self.navigationBar.translucent = NO;
    [self.navigationBar setNeedsLayout];
    [self.navigationBar setTitleVerticalPositionAdjustment:1.0 forBarMetrics:UIBarMetricsDefault]; // title center
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)setupAds {
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
    
    adsheight = CGSizeFromGADAdSize(kGADAdSizeBanner).height;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view{
    if(adstatus == NO) {
        CGRect frame = transitionView.frame;
        //CGRect frame = self.view.frame;
        frame.size.height -= adsheight;
        transitionView.frame = frame;
        adstatus = YES;
    }
}


-(void) viewDidAppear:(BOOL)animated {
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(addAds) userInfo:nil repeats:NO];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectcolor"];
    UIColor *tempcolor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    self.navigationBar.tintColor = [UIColor colorWithWhite:0 alpha:.9];
    [self.navigationController.navigationBar setBackgroundColor:tempcolor];
    [self.navigationController.navigationBar setTintColor:tempcolor];
    
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        self.navigationBar.barTintColor = tempcolor;
    } else {
        self.navigationBar.tintColor = tempcolor;
    }
}

-(void) addAds {
    if ([[params valueForKey:@"ADMOBVIEW"]intValue]) {
        [self setupAds];
    } else {
        [self removeAds];
    }
}

-(void) removeAds {
    if([self.view.subviews containsObject:bannerView_]) {
        CGRect frame = transitionView.frame;
        frame.size.height += adsheight;
        transitionView.frame = frame;
        adstatus = NO;
        
        for (UIView *subview in [self.view subviews]) {
            if([subview isKindOfClass:[GADBannerView class]]) {
                [subview removeFromSuperview];
            }
        }
    }
}

@end
