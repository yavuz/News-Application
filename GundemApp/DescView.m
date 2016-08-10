//
//  DescView.m
//  NewsApp
//
//  Created by yvzyldrm on 08/03/14.
//  Copyright (c) 2014 yvzyldrm. All rights reserved.
//

#import "DescView.h"
#import "NDViewController.h"
#import "NSString+HTML.h"
#import "UIImageView+FMNetworkImage.h"

@interface DescView () {
	CGFloat calculatedHeight;
}

@end

@implementation DescView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame setPItem:(GundemNews *) nitem {
    self = [self initWithFrame:frame];
    if (self) {
        self.pitem = nitem;
    }
    return self;
}

#pragma mark - Data

- (NSString*)descText {
    if(_pitem.content && ![_pitem.content isEqual:[NSNull null]] && _pitem.content != NULL ) {
        return _pitem.content.stringByConvertingHTMLToPlainText.stringByDecodingHTMLEntities;
    } else {
        return @"";
    }

}
- (void)setPitem:(GundemNews *)pitem {
	_pitem = pitem;
	if (!_pitem) {
		npagetitle.text = nil;
		npagetag = nil;
		npagedesc.attributedText = nil;
		npagedate.text = nil;
		npageimage.imageURL = nil;
		npageimage.image = nil;
		return;
	}
	
	npagetitle.text = _pitem.title;
    npagetag.text = [NSString stringWithFormat:@"%@/%@", _pitem.channelName, _pitem.channelCategory];
	npagedesc.attributedText = ({
		NSMutableAttributedString* attrStr;
#ifdef USE_OHAttributedLabel
		attrStr = [NSMutableAttributedString attributedStringWithString:_pitem.content.stringByConvertingHTMLToPlainText.stringByDecodingHTMLEntities];
		[attrStr setFont:npagedesc.font];
		OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
		paragraphStyle.lineSpacing = 5.f; // increase space between lines by 3 points
		[attrStr setParagraphStyle:paragraphStyle];
#else
		attrStr = [NSMutableAttributedString.alloc initWithString:self.descText attributes:self.attributesForDesc];
#endif
		attrStr;
	});

    npagedate.text = _pitem.dateString;
	
	if (![_pitem.imageUrl isEqual:@"false"]) {
		npageimage.netImage.completetionTarget = self;
		npageimage.netImage.completetionSelector = @selector(loadedImage:);
		npageimage.imageURL = [NSURL URLWithString:_pitem.imageUrl];
		npageimage.hidden = NO;
	} else {
		npageimage.hidden = YES;
	}
 
	[self setNeedsLayout];
}

- (UIImage*)loadedImage:(UIImage*)image {
	if (image) {
		if (image.size.width < 200) {
			npageimage.width = image.size.width + 50;
		}
		npageimage.height = image.size.height * (npageimage.width / image.size.width);
		npageimage.hidden = NO;
		[self layoutSubviews];
		[self.superview.superview setNeedsLayout]; // cok cirkin
	} else {
		npageimage.hidden = YES;
		[self layoutSubviews];
		[self.superview.superview setNeedsLayout]; // cok cirkin
	}
	return image;
}

#pragma mark - Layout

- (NSDictionary*)attributesForDesc {
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
	paragraphStyle.lineSpacing = 5;
	return @{
		NSFontAttributeName: npagedesc.font,
		NSParagraphStyleAttributeName: paragraphStyle
	};
}
- (void)loadView {
	self.backgroundColor = UIColor.whiteColor;
    
    CGFloat padwidth = self.width-40;
    
    npageline = [[UIView alloc] initWithFrame:CGRectMake(20, 117, padwidth, 1)];
    npageline.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    npageline.backgroundColor = [UIColor blackColor];
    [self addSubview:npageline];
    
    npagetopview = [[FMButton alloc] initWithFrame:CGRectMake(0, 12, 320, 89)];
    npagetopview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [npagetopview setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1] forState:UIControlStateHighlighted];
    [npagetopview addTarget:self action:@selector(newsRead:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:npagetopview];
    
    npagetitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, padwidth, 21)];
    npagetitle.numberOfLines = 0;
    npagetitle.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    npagetitle.font = [UIFont fontWithName:[params valueForKey:@"APPBOLDFONTNAME"] size:16.0];
    [self addSubview:npagetitle];
    
    npagetag = [[FMLabel alloc] initWithFrame:CGRectMake(20, 60, padwidth, 21)];
	npagetag.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:11.0];
    npagetag.padding = UIEdgeInsetsMake(0, 5, 2, 0);
    npagetag.layer.cornerRadius = 4;
    npagetag.textColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    [npagetag setBackgroundColor:[UIColor colorWithRed:216/255.0f green:216/255.0f blue:192/255.0f alpha:1.0f]];

    [self addSubview:npagetag];
    
    npagedate = [[FMLabel alloc] initWithFrame:CGRectMake(20, 6, padwidth, 21)];
    npagedate.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    npagedate.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:11.0];
    npagedate.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    [self addSubview:npagedate];
    
    npageimage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 192, padwidth, 128)];
    [self addSubview:npageimage];
    
#ifdef USE_OHAttributedLabel
    npagedesc = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(20, 399, 280, 21)];
#else
	npagedesc = [[UILabel alloc] initWithFrame:CGRectMake(20, 399, padwidth, 21)];
#endif
    npagedesc.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	npagedesc.textColor = [UIColor colorWithRed:81/255.0f green:81/255.0f blue:81/255.0f alpha:1.0f];
    npagedesc.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:14.0];
    npagedesc.numberOfLines = 0;
    [self addSubview:npagedesc];
    
    npagebutton = [[UIButton alloc] initWithFrame:CGRectMake(20, 371, 199, 25)];
    [npagebutton setTitle:NSLocalizedString(@"DescReadNews",nil) forState:UIControlStateNormal];
    [self addSubview:npagebutton];
    
    // Set the button Text Color
    npagebutton.titleLabel.font = [UIFont fontWithName:[params valueForKey:@"APPFONTNAME"] size:12.0];
    npagebutton.titleLabel.textColor = [UIColor blackColor];
    //[npagebutton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [npagebutton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [npagebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Set the button Background Color
    [npagebutton setBackgroundColor:[UIColor colorWithRed:216/255.0f green:216/255.0f blue:192/255.0f alpha:1.0f]];
    npagebutton.layer.cornerRadius = 4;
    [npagebutton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[npagebutton addTarget:self action:@selector(newsRead:) forControlEvents:UIControlEventTouchUpInside];

}
- (void)layoutSubviews {
	
    CGFloat lastTop = 0.0;
    CGFloat marginTop = 10.0;

    npagetopview.top = lastTop + 5.0;
    
    CGFloat viewlastTop = 0.0;
    
    npagedate.top = viewlastTop+marginTop;
    viewlastTop = npagedate.bottom;
    
    npagetitle.top = viewlastTop+1.0;
    
    CGSize size = [npagetitle.text sizeWithFont:npagetitle.font constrainedToSize:CGSizeMake(npagetitle.width, CGFLOAT_MAX)];
    npagetitle.height = size.height + 5;
    
    viewlastTop = npagetitle.bottom;
    
    npagetag.top = viewlastTop+5.0;
	size = [npagetag.text sizeWithFont:npagetag.font constrainedToSize:CGSizeMake(150, CGFLOAT_MAX)];
    size.width += 10;
    npagetag.width = size.width;
    
    viewlastTop = npagetag.bottom;
	
    npagetopview.height = viewlastTop + marginTop;
    lastTop = npagetopview.bottom;
    
    npageline.top = lastTop;
    lastTop = npageline.bottom;
    
    npageimage.top = lastTop + marginTop;
    if (npageimage.hidden == YES) {
        lastTop = npageimage.top;
    } else {
        lastTop = npageimage.bottom;
    }
    
    npagedesc.top = lastTop + marginTop;
    
#ifdef USE_OHAttributedLabel
	size = [npagedesc.attributedText sizeConstrainedToSize:CGSizeMake(npagedesc.width, CGFLOAT_MAX)];
#else
	size = [self.descText boundingRectWithSize:CGSizeMake(npagedesc.width, CGFLOAT_MAX)
									   options:NSStringDrawingUsesLineFragmentOrigin
									attributes:self.attributesForDesc context:nil].size;
#endif
    npagedesc.height = ceilf(size.height);
    
    lastTop = npagedesc.bottom;
    npagebutton.top = lastTop + marginTop;
	
	calculatedHeight = npagebutton.bottom + marginTop + 15.0;
	self.height = calculatedHeight;
    [(NDViewController*)self.parentViewController viewDidLayoutSubviews];
}

- (CGFloat)optimumHeight {
	return calculatedHeight;
}

- (IBAction)newsRead:(id)sender {
    [(NDViewController*)self.parentViewController newsRead:_pitem.link];
}

@end
