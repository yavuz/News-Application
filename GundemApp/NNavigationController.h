//
//  NNavigationController.h
//  NewsApp
//
//  Created by yvzyldrm on 8/24/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"


@interface NNavigationController : UINavigationController<GADBannerViewDelegate> {
    GADBannerView *bannerView_;
    UIView* transitionView;
    BOOL adstatus;
    CGFloat adsheight;
}

@end
