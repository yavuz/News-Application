//
//  NWebController.h
//  NewsApp
//
//  Created by yvzyldrm on 8/27/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>


@interface NWebController : UIViewController<UIWebViewDelegate,GADBannerViewDelegate>{
    IBOutlet UIWebView *nwebView;
    IBOutlet UINavigationBar *WebNavigation;
    IBOutlet UIButton *backbutton;
    IBOutlet UIView *statusColor;
    GADBannerView *bannerView_;
}


- (void)setUpImageBackButton;

@property (nonatomic,retain) NSString *webLink;
@property (nonatomic,retain) IBOutlet UIWebView *nwebView;
-(void) setWebLink:(NSString *)webLink;

@end
