#define _FMLabel_QUARTZ_SUPPORT 1

#import "FMLabel.h"
#ifdef _FMLabel_QUARTZ_SUPPORT
#import <QuartzCore/QuartzCore.h>
#endif

#ifndef screenScale
#define screenScale [[UIScreen mainScreen] scale]
#endif

@interface FMLabel (Private)
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) UIImageView* leftImageView;
@property (nonatomic, assign) UIImageView* rightImageView;
@end

@implementation FMLabel

- (void)setup {
	// Initialization code
	_leftIconPlacement = FMLabelImagePlacementHorizontalStickToText | FMLabelImagePlacementVerticalMiddle | FMLabelImagePlacementVerticalOnText;
	_rightIconPlacement = FMLabelImagePlacementHorizontalStickToText | FMLabelImagePlacementVerticalMiddle | FMLabelImagePlacementVerticalOnText;
	realLabel = [UILabel.alloc initWithFrame:self.bounds].autorelease;
	realLabel.backgroundColor = UIColor.clearColor;
	[self addSubview:realLabel];
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		super.backgroundColor = UIColor.clearColor;
		[self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
		realLabel.text = super.text; [super setText:nil];
		realLabel.textColor = super.textColor;
		realLabel.shadowColor = super.shadowColor;
		realLabel.textAlignment = super.textAlignment;
		realLabel.shadowOffset = super.shadowOffset;
		realLabel.font = super.font;
		realLabel.numberOfLines = super.numberOfLines;
		realLabel.minimumScaleFactor = super.minimumScaleFactor;
		realLabel.backgroundColor = super.backgroundColor;
		[self applySizes];
		[self applyPositioning];
	}
	return self;
}
- (void)dealloc {
    self.leftIconImage = nil;
	self.rightIconImage = nil;
    [super dealloc];
}
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	[realLabel sizeToFit];
	CGRect theRect = [realLabel textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	theRect.origin.y += _padding.top;
	theRect.origin.x += _padding.left;
	theRect.size = _textSize;
	CGFloat leftIconNeeds = 0;
	CGFloat rightIconNeeds = 0;
	if (_leftIconImage) {
		leftIconNeeds = _leftIconImage.size.width + _leftIconSpacing.left + _leftIconSpacing.right;
	}
	if (_rightIconImage) {
		rightIconNeeds = _rightIconImage.size.width + _rightIconSpacing.left + _rightIconSpacing.right;
	}
	if (realLabel.textAlignment == NSTextAlignmentRight) {
		// ..
	} else if (realLabel.textAlignment == NSTextAlignmentLeft) {
		theRect.origin.x += leftIconNeeds;
	} else {
		// default :/
		theRect.origin.x += floorf(leftIconNeeds / 2);
		theRect.origin.x -= floorf(rightIconNeeds / 2);
	}
	if (theRect.size.width > self.bounds.size.width - rightIconNeeds - leftIconNeeds) {
		CGFloat finalSize = realLabel.font.pointSize;
		theRect.size = [realLabel.text sizeWithFont:realLabel.font
                                        minFontSize:realLabel.font.pointSize * realLabel.minimumScaleFactor
                                     actualFontSize:&finalSize
                                           forWidth:self.bounds.size.width - rightIconNeeds - leftIconNeeds
                                      lineBreakMode:realLabel.lineBreakMode];
	}
	if (self.contentMode & UIViewContentModeCenter) {
		theRect.origin.y = floorf((self.bounds.size.height - (_padding.top + _padding.bottom) - theRect.size.height) / 2);
		theRect.origin.y += _padding.top;
	}
 	_textRect = theRect;
	return theRect;
}
- (void)applyColors {
	if (_colorizeImages) {
		//self.leftImageView.image = [_leftIconImage colorizedImage:realLabel.textColor];
		//self.rightImageView.image = [_rightIconImage colorizedImage:realLabel.textColor];
	} else {
		self.leftImageView.image = _leftIconImage;
		self.rightImageView.image = _rightIconImage;
	}
}
- (void)applyShadows {
	if (_shadowAppliesToImages) {
		
		_leftImageView.layer.shadowOpacity = 1;
		_leftImageView.layer.shadowOffset = realLabel.shadowOffset;
		_leftImageView.layer.shadowColor = realLabel.shadowColor.CGColor;
		_leftImageView.layer.shadowRadius = 0;
		_leftImageView.layer.shouldRasterize = YES;
		_leftImageView.layer.rasterizationScale = screenScale;
		
		_rightImageView.layer.shadowOpacity = 1;
		_rightImageView.layer.shadowOffset = realLabel.shadowOffset;
		_rightImageView.layer.shadowColor = realLabel.shadowColor.CGColor;
		_rightImageView.layer.shadowRadius = 0;
		_rightImageView.layer.shouldRasterize = YES;
		_rightImageView.layer.rasterizationScale = screenScale;
	} else {
		
		_leftImageView.layer.shadowOpacity = 0;
		_leftImageView.layer.shadowRadius = 0;
		_rightImageView.layer.shadowOpacity = 0;
		_rightImageView.layer.shadowRadius = 0;
	}
}
- (void)applySizes {
	_textSize = [realLabel.text sizeWithFont:realLabel.font constrainedToSize:self.bounds.size];
    //	_textSize.width += _padding.left + _padding.right;
    //	_textSize.height += _padding.top + _padding.top;
	[self setNeedsDisplay];
}
- (void)applyPositioningToImageView:(UIImageView*)imageView placement:(FMLabelImagePlacement)placement spacing:(UIEdgeInsets)spacing onLeft:(BOOL)left {
	if (!imageView) return;
	
	CGPoint location = CGPointMake(0, 0);
	CGSize selfSize = self.bounds.size;
	CGSize imageSize = imageView.image.size;
    
	// vertical
	if (placement & FMLabelImagePlacementVerticalOnText) {
		if (placement & FMLabelImagePlacementVerticalMiddle) { // this has to be the first
			location.y = floorf((_textRect.size.height / 2) - (imageSize.height / 2) + spacing.top/2 - spacing.bottom/ 2);
		} else if (placement & FMLabelImagePlacementVerticalTop) {
			location.y = spacing.top;
		} else if (placement & FMLabelImagePlacementVerticalBottom) {
			location.y = _textRect.size.height - imageSize.height - spacing.bottom;
		}
		location.y += _textRect.origin.y;
	} else { // on borders
		if (placement & FMLabelImagePlacementVerticalMiddle) { // this has to be the first
			location.y = floorf((selfSize.height / 2) - (imageSize.height / 2) - ((spacing.top + spacing.bottom) / 2));
		} else if (placement & FMLabelImagePlacementVerticalTop) {
			location.y = spacing.top;
		} else if (placement & FMLabelImagePlacementVerticalBottom) {
			location.y = selfSize.height - imageSize.height - spacing.bottom;
		}
	}
	
	// horizontal
	if (placement & FMLabelImagePlacementHorizontalStickToBorder) {
		location.x = left ? spacing.left : selfSize.width - spacing.right - imageSize.width;
	} else {
		if (realLabel.textAlignment == NSTextAlignmentCenter) {
			if (left)
				location.x = -imageSize.width - spacing.right;
			else
				location.x = _textRect.size.width + spacing.left;
		} else if (realLabel.textAlignment == NSTextAlignmentRight) {
			if (left)
				location.x = -imageSize.width - spacing.right;
			else
				location.x = _textRect.size.width + spacing.left;
		} else { // take it as left (in future: consider checking Natural one)
			location.x = left ? spacing.left : _textRect.size.width + spacing.left;
		}
		location.x += _textRect.origin.x;
	}
	imageView.frame = CGRectMake(location.x, location.y, imageSize.width, imageSize.height);
}
- (void)applyPositioning {
	realLabel.frame = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
	[self applyPositioningToImageView:self.leftImageView placement:self.leftIconPlacement spacing:self.leftIconSpacing onLeft:YES];
	[self applyPositioningToImageView:self.rightImageView placement:self.rightIconPlacement spacing:self.rightIconSpacing onLeft:NO];
}
- (void)setTextColor:(UIColor *)textColor {
	[realLabel setTextColor:textColor];
	[self applyColors];
}
- (UIColor *)textColor { return realLabel.textColor; }
- (void)setShadowColor:(UIColor *)shadowColor {
	[realLabel setShadowColor:shadowColor];
	[self applyShadows];
}
- (UIColor *)shadowColor { return realLabel.shadowColor; }
- (void)setShadowOffset:(CGSize)shadowOffset {
	[realLabel setShadowOffset:shadowOffset];
	[self applyShadows];
}
- (CGSize)shadowOffset { return realLabel.shadowOffset; }
- (void)setText:(NSString *)text {
	[realLabel setText:text];
	[self applySizes];
	[self applyPositioning];
}
- (NSString *)text { return realLabel.text; }
- (void)setFont:(UIFont *)font {
	[realLabel setFont:font];
	[self applySizes];
	[self applyPositioning];
}
- (UIFont *)font { return realLabel.font; }
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
	[realLabel setTextAlignment:textAlignment];
	[self applyPositioning];
}
- (NSTextAlignment)textAlignment { return realLabel.textAlignment; }
- (void)setMinimumScaleFactor:(CGFloat)minimumScaleFactor {
	[realLabel setMinimumScaleFactor:minimumScaleFactor];
	[self applyPositioning];
}
- (CGFloat)minimumScaleFactor { return realLabel.minimumScaleFactor; }
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
	[realLabel setLineBreakMode:lineBreakMode];
	[self applyPositioning];
}
- (NSLineBreakMode)lineBreakMode { return realLabel.lineBreakMode; }
- (void)setNumberOfLines:(NSInteger)numberOfLines {
	realLabel.numberOfLines = numberOfLines;
	[self applySizes];
	[self applyPositioning];
}
- (NSInteger)numberOfLines { return realLabel.numberOfLines; }
- (void)setBackgroundColor:(UIColor *)backgroundColor {
	realLabel.backgroundColor = backgroundColor;
	super.backgroundColor = backgroundColor;
}
- (UIColor *)backgroundColor { return realLabel.backgroundColor; }
- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self applySizes];
	[self applyPositioning];
}
- (void)setShadowAppliesToImages:(BOOL)shadowAppliesToImages {
	_shadowAppliesToImages = shadowAppliesToImages;
	[self applyShadows];
}
- (void)setColorizeImages:(BOOL)colorizeImages {
	_colorizeImages = colorizeImages;
	[self applyColors];
}
- (void)layoutSubviews {
	[super layoutSubviews];
	[self applySizes];
	[self applyPositioning];
}

- (void)setPadding:(UIEdgeInsets)padding {
	if (UIEdgeInsetsEqualToEdgeInsets(padding, _padding)) return;
	CGSize diff;
	diff.width = (padding.right + padding.left) - (_padding.right + padding.left);
	diff.height = (padding.bottom + padding.top) - (_padding.bottom + _padding.top);
	
	_padding = padding;
	
	super.frame = ({
		CGRect frame = super.frame;
		frame.size.width += diff.width;
		frame.size.height += diff.height;
		frame;
	});
	[self layoutSubviews];
}

- (void)setLeftImageView:(UIImageView *)leftImageView {
	[_leftImageView removeFromSuperview]; _leftImageView = leftImageView;
	[self addSubview:_leftImageView];
	[self applyPositioning];
}
- (void)setRightImageView:(UIImageView *)rightImageView {
	[_rightImageView removeFromSuperview]; _rightImageView = rightImageView;
	[self addSubview:_rightImageView];
	[self applyPositioning];
}

- (void)setLeftIconImage:(UIImage *)leftIconImage {
	[_leftIconImage autorelease]; _leftIconImage = [leftIconImage retain];
	if (!_leftImageView)
		self.leftImageView = _leftIconImage ? UIImageView.new.autorelease : nil;
	[self applyColors];
	[self applyShadows];
	[self applyPositioning];
}
- (void)setRightIconImage:(UIImage *)rightIconImage {
	[_rightIconImage autorelease]; _rightIconImage = [rightIconImage retain];
	if (!_rightImageView)
		self.rightImageView = _rightIconImage ? UIImageView.new.autorelease : nil;
	[self applyColors];
	[self applyShadows];
	[self applyPositioning];
}



@end
