//
//  DescView.h
//  NewsApp
//
//  Created by yvzyldrm on 08/03/14.
//  Copyright (c) 2014 yvzyldrm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"
#import "FMDatabase.h"
#import <QuartzCore/QuartzCore.h>
#import "FMLabel.h"
#import "FMButton.h"
#import "GundemNews.h"

//#define USE_OHAttributedLabel
//#import <OHAttributedLabel/OHAttributedLabel.h>

@interface DescView : UIView {
    UIView *npageline;
    UILabel *npagedate;
    FMLabel *npagetag;
    FMButton *npagetopview;
    UILabel *npagetitle;
    UIImageView *npageimage;
#ifdef USE_OHAttributedLabel
    OHAttributedLabel *npagedesc;
#else
	UILabel* npagedesc;
#endif
    FMLabel *npageread;
    UIButton *npagebutton;
    UIScrollView *nDescPageView;
}

- (id)initWithFrame:(CGRect)frame setPItem:(GundemNews *) item;
- (CGFloat)optimumHeight;

@property (nonatomic,strong) GundemNews *pitem;
@property (nonatomic,strong) NSMutableDictionary *item;
@property (nonatomic,weak) UIViewController* parentViewController;

@end
