//
//  NDViewController.m
//  NewsApp
//
//  Created by yvzyldrm on 08/03/14.
//  Copyright (c) 2014 yvzyldrm. All rights reserved.
//

#import "NDViewController.h"
#import "NListController.h"
#import "AAPullToRefresh.h"

@interface NDViewController () <UIScrollViewDelegate> {
	AAPullToRefresh *topPullView;
	AAPullToRefresh *bottomPullView;
}

@property (nonatomic, strong) UIView *thresholdView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation NDViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
	self.view = [UIView.alloc initWithFrame:UIScreen.mainScreen.bounds];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight + UIViewAutoresizingFlexibleWidth;
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
	//    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.contentSize = self.view.bounds.size;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];

	__block NDViewController* selfPointer = self;
	
	topPullView = [self.scrollView addPullToRefreshPosition:AAPullToRefreshPositionTop actionHandler:^(AAPullToRefresh *v){
		[selfPointer switchToPreviousNews];
	}];

	bottomPullView = [self.scrollView addPullToRefreshPosition:AAPullToRefreshPositionBottom actionHandler:^(AAPullToRefresh *v){
		[selfPointer switchToNextNews];
	}];
    
}

- (void)switchToPreviousNews {
	self.previousNewsView.height = self.previousNewsView.optimumHeight;
	self.previousNewsView.top = 0;
	self.previousNewsView.alpha = 1;
	[self.scrollView addSubview:self.previousNewsView];
	self.currentNewsView.top = self.previousNewsView.height < self.scrollView.height ? self.scrollView.height : self.previousNewsView.height;
	CGFloat contentHeight = self.previousNewsView.height < self.scrollView.height ? self.scrollView.height : self.previousNewsView.height;
	contentHeight += self.currentNewsView.height < self.scrollView.height ? self.scrollView.height : self.currentNewsView.height;
	self.scrollView.contentSize = CGSizeMake(0, contentHeight);
	[self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y + self.currentNewsView.top) animated:NO];
	topPullView.hidden = YES;
	[UIView animateWithDuration:.4 delay:0 options:0 animations:^{
		[topPullView stopIndicatorAnimationAnimated:NO];
		self.previousNewsView.alpha = 1;
		self.currentNewsView.alpha = 0;
		[self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
	} completion:^(BOOL finished) {
		// shift left
		[self.currentNewsView removeFromSuperview];
		self.currentNewsView = self.previousNewsView;
		
		self.currentNews = self.previousNews;
		
		topPullView.hidden = NO;
		[self resetPullViews];
		[self.view setNeedsLayout];
	}];
}

- (void)resetPullViews {
	topPullView.showPullToRefresh = self.previousNews ? YES : NO;
	bottomPullView.showPullToRefresh = self.nextNews ? YES : NO;
}

- (void)switchToNextNews {
	self.nextNewsView.top = self.scrollView.contentSize.height - 1;
	self.nextNewsView.alpha = 0;
	self.nextNewsView.height = self.nextNewsView.optimumHeight;
	[self.scrollView addSubview:self.nextNewsView];
	
	CGFloat secondScrollSize = self.nextNewsView.height < self.scrollView.height ? self.nextNewsView.top + self.scrollView.height : self.nextNewsView.bottom;
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, secondScrollSize);
	
	bottomPullView.hidden = YES;
	[UIView animateWithDuration:.4 delay:0 options:0 animations:^{
		[bottomPullView stopIndicatorAnimationAnimated:NO];
		self.nextNewsView.alpha = 1;
		self.currentNewsView.alpha = 0;
		[self.scrollView setContentOffset:CGPointMake(0, self.nextNewsView.top + self.scrollView.contentInset.top) animated:NO];
	} completion:^(BOOL finished) {
		// shift left
		[self.currentNewsView removeFromSuperview];
		self.currentNewsView = self.nextNewsView;
		
		self.currentNews = self.nextNews;
        
		self.currentNewsView.top = 0;
		self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentInset.top);
        
		bottomPullView.hidden = NO;
		[self resetPullViews];
		[self.view setNeedsLayout];
	}];
}

- (DescView *)nextNewsView {
	if (!_nextNewsView) {
		self.nextNewsView = [self descViewForData:self.nextNews];
	}
	return _nextNewsView;
}
- (DescView *)previousNewsView {
	if (!_previousNewsView) {
		self.previousNewsView = [self descViewForData:self.previousNews];
	}
	return _previousNewsView;
}

- (void)setCurrentNews:(GundemNews *)currentNews {
	if (currentNews == _currentNews) return;
	_currentNews = currentNews;
	self.nextNews = [self.delegate nextNewsForNews:_currentNews];
	self.previousNews = [self.delegate previousNewsForNews:_currentNews];
}
- (void)setNextNews:(GundemNews *)nextNews {
	_nextNews = nextNews;
	self.nextNewsView = nil;
}
- (void)setPreviousNews:(GundemNews *)previousNews {
	_previousNews = previousNews;
	self.previousNewsView = nil;
}

- (DescView*)descViewForData:(GundemNews*)newsData {
	DescView* descView = [DescView.alloc initWithFrame:self.view.bounds setPItem:newsData];
	descView.parentViewController = self;
	return descView;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGFloat scrollHeight = self.currentNewsView.height;
	if (scrollHeight <= self.scrollView.bounds.size.height)
		scrollHeight = self.scrollView.bounds.size.height + 1;
	self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, scrollHeight);
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.currentNewsView = [self descViewForData:self.currentNews];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.scrollView addSubview:self.currentNewsView];
	[self resetPullViews];
    [self setUpImageBackButton];
    self.title = NSLocalizedString(@"DescTitle",nil);
    self.nlink = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)newsRead:(NSString *)nurl {
    NWebController *NWebController = [self.storyboard instantiateViewControllerWithIdentifier:@"NWebController"];
    NWebController.webLink = nurl;
    NWebController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController presentViewController:NWebController animated:YES completion:nil];
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
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 19, 27)];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"sharing.png"] forState:UIControlStateNormal];
    UIBarButtonItem *barshareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [shareButton addTarget:self action:@selector(shareNews) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = barshareButtonItem;
}

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)shareNews
{
    UIImage *anImage = [UIImage imageNamed:@"sharepic.png"];
    
    if(![self.currentNews.imageUrl isEqual: @"false"]) {
        NSURL *url = [NSURL URLWithString:self.currentNews.imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        anImage = [[UIImage alloc] initWithData:data];
    }
    
    NSURL *nlink = nil;
    if(self.currentNews.link) {
        nlink = [NSURL URLWithString:self.currentNews.link];
    }
    
    
    NSString *temptext = [NSString stringWithFormat:@"%@  ",self.currentNews.title];
    NSMutableArray *Items   = [NSMutableArray arrayWithObjects:
                               temptext,
                               anImage, nlink, nil];
    
    ActivityView =
    [[UIActivityViewController alloc]
     initWithActivityItems:Items applicationActivities:nil];
    
    NSLog(@"ippppp22");
    
    NSRange ipadRange = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if(ipadRange.location != NSNotFound) {
        NSLog(@"ippppp11");
        if ([ActivityView respondsToSelector:@selector(popoverPresentationController)]) { // iOS8
            NSLog(@"ippppp");
            ActivityView.popoverPresentationController.sourceView = self.view;
            
        }
    }
    NSLog(@"ssdsdsd");
    
    [self presentViewController:ActivityView animated:YES completion:nil];
    
    
}

@end
