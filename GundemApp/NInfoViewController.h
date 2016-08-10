//
//  NInfoViewController.h
//  NewsApp
//
//  Created by yvzyldrm on 9/3/13.
//  Copyright (c) 2013 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMButton.h"
#import "FMDatabase.h"
#import "MBProgressHUD.h"
#import "JSFlatButton.h"

@interface NInfoViewController : UIViewController<MBProgressHUDDelegate/*,IAPProductObserver*/>{
    IBOutlet UINavigationBar *InfoNavigation;
    IBOutlet UITextView *NInfoDesc;
    IBOutlet JSFlatButton *rateButton;
    IBOutlet JSFlatButton *shareButton;
    IBOutlet JSFlatButton *cacheButton;
    IBOutlet UIView *nline;
    IBOutlet UILabel *notherLabel;
    IBOutlet FMButton *nadsview;
    IBOutlet UIImageView *nadsimage1;
    IBOutlet UILabel *nadstext1;
    IBOutlet UIImageView *yappsLabel;
    IBOutlet UIScrollView *nscrollView;
    IBOutlet UIButton *backbutton;
    IBOutlet UIView *statusColor;
    IBOutlet UIView *ncolorline;
    IBOutlet JSFlatButton *color1;
    IBOutlet JSFlatButton *color2;
    IBOutlet JSFlatButton *color3;
    IBOutlet JSFlatButton *color4;
    IBOutlet JSFlatButton *color5;
    IBOutlet UILabel *ncolorLabel;
    MBProgressHUD *HUD;
    UIActivityViewController *ActivityView;
    
    FMDatabase *database;
}

@property(nonatomic,retain) UIActivityViewController *ActivityView;
- (IBAction)openRate: (id) sender;
- (void)openShare: (id) sender;

@end
