//
//  UIView+extend.m
//  YKY-iPad
//
//

#import "FMUIView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#pragma mark - UIView Category

@implementation UIView (Framing)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end

//static char saneConstraintKey;
//@implementation UIView (SaneConstraint)
//
//- (void)addSaneConstraintBlock:(void(^)(UIView* view, CGRect oldFrame, CGRect newFrame))block {
////	void (^oldBlock)(UIView* view, CGRect oldFrame, CGRect newFrame);
////	oldBlock = objc_getAssociatedObject(self, &saneConstraintKey);
//	objc_setAssociatedObject(self, &saneConstraintKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//- (void)newSetframe
//
//@end

@implementation UIView (ResponderChain)

- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}

@end

@implementation UIView (LiveShots)

- (UIImage *)captureRect:(CGRect)captureFrame {
    CALayer *layer;
    layer = self.layer;
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

	if (CGRectEqualToRect(captureFrame, self.bounds))
		return screenImage;

	CGImageRef cropCGImage = CGImageCreateWithImageInRect(screenImage.CGImage, captureFrame);
	UIImage *cropImage = [[[UIImage alloc] initWithCGImage:cropCGImage] autorelease];
	CGImageRelease(cropCGImage);
    return cropImage;
}

@end

@implementation FMUIView

- (void)dealloc {
	self.drawingMethods = nil;
	[super dealloc];
}
- (NSMutableArray *)drawingMethods {
	if (!_drawingMethods)
		_drawingMethods = NSMutableArray.new;
	return _drawingMethods;
}
-(void)addDrawingMethod:(void(^)(CGContextRef context, UIView* view, CGRect rect))method {
	self.contentMode = UIViewContentModeRedraw;
	[self.drawingMethods addObject:method];
	[self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect {
	if (self.drawingMethods.count > 0) {
		CGContextRef currentContext = UIGraphicsGetCurrentContext();
		for (void(^method)(CGContextRef context, UIView* view, CGRect rect) in self.drawingMethods) {
			method(currentContext, self, rect);
		}
	}
	[super drawRect:rect];
}

-(void)addSubviewFadingIn:(UIView *)view {
	view.alpha = 0;
	[self addSubview:view];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	
	view.alpha = 1;
	
	[UIView commitAnimations];
}

-(void)removeFromSuperviewFadingOut {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.4];
	
	self.alpha = 0;
	
	[UIView commitAnimations];
	[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.5];
}

-(void)stretchImageViewsWithTag:(NSUInteger)tag leftCap:(CGFloat)lc topCap:(CGFloat)tc {
	for (UIImageView* i in self.subviews) {
		if (i.tag!=tag || ![i isKindOfClass:[UIImageView class]]) continue;
		i.image = [i.image stretchableImageWithLeftCapWidth:lc topCapHeight:tc];
	}
}

-(void)setBackgroundImage:(UIImage*)image leftCap:(CGFloat)lc topCap:(CGFloat)tc {
	UIImageView* background = (UIImageView*)[self viewWithTag:976342];
	if (!background) {
		background = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
		background.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
		[self addSubview:background];
		[self sendSubviewToBack:background];
	}
	if (lc>0 || tc>0) image = [image stretchableImageWithLeftCapWidth:lc topCapHeight:tc];
	background.image = image;
}

@end

@implementation UIWebView (FMUIWebView)

- (void)setBackgroundColor:(UIColor *)backgroundColor andShadows:(BOOL)shadows {

	self.backgroundColor = backgroundColor;	
	[(UIView*)[self.subviews objectAtIndex:0] setBackgroundColor:backgroundColor];
	
	if (!shadows) {
		for (UIView* subView in [[self.subviews objectAtIndex:0] subviews]) {
			if ([subView isKindOfClass:[UIImageView class]]) {
				subView.alpha = 0;
				[(UIImageView*)subView setImage:nil];
			} else {
				subView.backgroundColor = backgroundColor;
				subView.opaque = false;
			}
		}
	}else{
		//TODO: HAVENT FIGURED OUT HOW TO RE-ENABLE SHADOWS YET
	}
}

- (void)setScrollable:(BOOL)scrollable {
	[(UIScrollView*)[self.subviews objectAtIndex:0] setScrollEnabled:scrollable];
}

@end

@implementation FMUITextField

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return CGRectMake(self.insets.left + self.leftView.bounds.size.width, self.insets.top,
					  bounds.size.width - self.insets.left - self.insets.right - self.rightView.bounds.size.width - self.leftView.bounds.size.width,
					  bounds.size.height - self.insets.top - self.insets.bottom);
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return [self editingRectForBounds:bounds];
}
- (CGRect)textRectForBounds:(CGRect)bounds {
	return [self editingRectForBounds:bounds];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
	return CGRectMake(bounds.size.width - self.insets.right - self.rightView.bounds.size.width, self.insets.top,
					  self.rightView.bounds.size.width,
					  self.rightView.bounds.size.height);
}
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
	return CGRectMake(self.insets.left, self.insets.top,
					  self.rightView.bounds.size.width,
					  self.rightView.bounds.size.height);
}

@end

@implementation UIButton (FMUIButton)

- (void)addIconToLeft:(UIImage*)icon {
	UILabel* label = [self.titleLabel copy].autorelease;
	CGFloat totalWidth = label.frame.size.width + icon.size.width + 5;
	CGFloat right = floorf((self.frame.size.width / 2) + (totalWidth / 2));
	CGFloat left = floorf((self.frame.size.width / 2) - (totalWidth / 2));
	CGFloat top = floorf((self.frame.size.height / 2) - (icon.size.height / 2));
	
	UIImageView* iconView = [[[UIImageView alloc] initWithImage:icon] autorelease];
	iconView.frame = CGRectMake(left, top, icon.size.width, icon.size.height);
	[self addSubview:iconView];
	
	CGRect labelFrame = label.frame;
	labelFrame.origin.x = right - label.frame.size.width;
	label.frame = labelFrame;
	[self addSubview:label];
	[self setTitle:@"" forState:UIControlStateNormal];
}

- (void)addIconToRight:(UIImage*)icon {
	UILabel* label = [self.titleLabel copy].autorelease;
	CGFloat totalWidth = label.frame.size.width + icon.size.width + 5;
	CGFloat right = floorf((self.frame.size.width / 2) + (totalWidth / 2));
	CGFloat left = floorf((self.frame.size.width / 2) - (totalWidth / 2));
	CGFloat top = floorf((self.frame.size.height / 2) - (icon.size.height / 2));
	
	UIImageView* iconView = [[[UIImageView alloc] initWithImage:icon] autorelease];
	iconView.frame = CGRectMake(right - icon.size.width, top, icon.size.width, icon.size.height);
	[self addSubview:iconView];
	
	CGRect labelFrame = label.frame;
	labelFrame.origin.x = left;
	label.frame = labelFrame;
	[self addSubview:label];
	[self setTitle:@"" forState:UIControlStateNormal];
}

@end

@implementation UILabel (FMUILabel)

-(UILabel*)copy {
	UILabel* newLabel = [[UILabel alloc] initWithFrame:self.frame];
	newLabel.font = self.font;
	newLabel.text = self.text;
	newLabel.opaque = self.opaque;
	newLabel.textColor = self.textColor;
	newLabel.shadowColor = self.shadowColor;
	newLabel.shadowOffset = self.shadowOffset;
	newLabel.alpha = self.alpha;
	newLabel.backgroundColor = self.backgroundColor;
	newLabel.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth;
	return newLabel;
}

@end

@implementation dummyViewController

+(UIViewController*)controllerWithView:(UIView*)view {
	UIViewController* ctrl = [[[dummyViewController alloc] init] autorelease];
	ctrl.view = view;
	return ctrl;
}

@end
//
//@implementation UICollectionViewLayout (invalidateScheduler)
//
//- (void)invalidateLayoutOnTheProperThread {
//	onMainQueue(^{
//		[self invalidateLayout];
//	});
//}
//- (void)scheduleInvalidateTimeout {
//	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(invalidateLayoutOnTheProperThread) object:nil];
//	[self performSelector:@selector(invalidateLayoutOnTheProperThread) withObject:nil afterDelay:.01];
//}
//
//@end

@implementation UIScrollView (FMStackedInsets)
@dynamic insetCollection;

static char _FMStackedInsets_insetCollectionKey;
- (NSMutableDictionary*)insetCollection {
	return objc_getAssociatedObject(self, &_FMStackedInsets_insetCollectionKey);
}
- (void)setInsetCollection:(NSMutableDictionary *)insetCollection {
	objc_setAssociatedObject(self, &_FMStackedInsets_insetCollectionKey, insetCollection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setInsets:(UIEdgeInsets)insets withIdentifier:(id)identifier {
	if (!self.insetCollection)
		self.insetCollection = NSMutableDictionary.dictionary;
	id thekey = [NSString stringWithFormat:@"%02lx", (unsigned long)identifier];
	
	[self.insetCollection setObject:[NSValue valueWithUIEdgeInsets:insets] forKey:thekey];
	[self refreshInsets];
}
- (UIEdgeInsets)insetsWithoutIdentifiers:(NSArray*)identifiers {
	if (!self.insetCollection || self.insetCollection.count == 0) return UIEdgeInsetsZero;
	
	NSMutableArray* keys = NSMutableArray.array;
	for (id identifier in identifiers) {
		NSString* aKey = [NSString stringWithFormat:@"%02lx", (unsigned long)identifier];
		if (![self.insetCollection objectForKey:aKey]) continue;
		[keys addObject:aKey];
	}
	
	__block UIEdgeInsets finalInsets = UIEdgeInsetsZero;
	[self.insetCollection enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		for (id aKey in keys)
			if ([key isEqual:aKey]) return;
		UIEdgeInsets insets = [(NSValue*)obj UIEdgeInsetsValue];
		finalInsets.top += insets.top;
		finalInsets.bottom += insets.bottom;
		finalInsets.left += insets.left;
		finalInsets.right += insets.right;
	}];
	return finalInsets;
}
- (UIEdgeInsets)insetsWithoutIdentifier:(id)identifier {
	if (!self.insetCollection || self.insetCollection.count == 0) return UIEdgeInsetsZero;
	
	id thekey = [NSString stringWithFormat:@"%02lx", (unsigned long)identifier];

	__block UIEdgeInsets finalInsets = UIEdgeInsetsZero;
	[self.insetCollection enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([key isEqual:thekey]) return;
		UIEdgeInsets insets = [(NSValue*)obj UIEdgeInsetsValue];
		finalInsets.top += insets.top;
		finalInsets.bottom += insets.bottom;
		finalInsets.left += insets.left;
		finalInsets.right += insets.right;
	}];
	return finalInsets;
}
- (void)refreshInsets {
	if (!self.insetCollection) return;
	
	UIEdgeInsets finalInsets = UIEdgeInsetsZero;
	for (NSValue* insetValue in self.insetCollection.allValues) {
		UIEdgeInsets insets = [insetValue UIEdgeInsetsValue];
		finalInsets.top += insets.top;
		finalInsets.bottom += insets.bottom;
		finalInsets.left += insets.left;
		finalInsets.right += insets.right;
	}
	self.contentInset = finalInsets;
}
- (void)removeInsetsForIdentifier:(id)identifier {
	id key = [NSString stringWithFormat:@"%02lx", (unsigned long)identifier];
	[self.insetCollection removeObjectForKey:key];
	if (self.insetCollection.count==0)
		self.insetCollection = nil;
	[self refreshInsets];
}

@end
