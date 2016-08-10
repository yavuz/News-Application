//
//  UIView+extend.h
//
//

#import <UIKit/UIKit.h>

@interface UIView (Framing)

@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign, readonly) CGFloat right;
@property(nonatomic, assign, readonly) CGFloat bottom;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;

@end

//@interface UIView (SaneConstraint)
//
//- (void)addSaneConstraintBlock:(void(^)(UIView* view, CGRect oldFrame, CGRect newFrame))block;
//
//@end

@interface UIView (ResponderChain)

- (BOOL)findAndResignFirstResponder;

@end

@interface UIView (LiveShots)

- (UIImage *)captureRect:(CGRect)captureFrame;

@end

@interface FMUIView : UIView

-(void)addSubviewFadingIn:(UIView *)view;
-(void)removeFromSuperviewFadingOut;
-(void)stretchImageViewsWithTag:(NSUInteger)tag leftCap:(CGFloat)lc topCap:(CGFloat)tc;
-(void)setBackgroundImage:(UIImage*)image leftCap:(CGFloat)lc topCap:(CGFloat)tc;

-(void)addDrawingMethod:(void(^)(CGContextRef context, UIView* view, CGRect rect))method;

@property (nonatomic,retain) NSMutableArray* drawingMethods;

@end

@interface UIWebView (FMUIWebView)

- (void)setBackgroundColor:(UIColor *)backgroundColor andShadows:(BOOL)shadows;
- (void)setScrollable:(BOOL)scrollable;

@end

@interface FMUITextField : UITextField

@property (nonatomic,readwrite) UIEdgeInsets insets;

@end

@interface UIButton (FMUIButton)

- (void)addIconToLeft:(UIImage*)icon;
- (void)addIconToRight:(UIImage*)icon;

@end

@interface UILabel (FMUILabel)

-(UILabel*)copy;

@end

@interface dummyViewController : UIViewController

+(UIViewController*)controllerWithView:(UIView*)view;

@end
//
//@interface UICollectionViewLayout (invalidateScheduler)
//
//- (void)scheduleInvalidateTimeout;
//
//@end

@interface UIScrollView (FMStackedInsets)

- (void)setInsets:(UIEdgeInsets)insets withIdentifier:(id)identifier;
- (void)removeInsetsForIdentifier:(id)identifier;
- (UIEdgeInsets)insetsWithoutIdentifier:(id)identifier;
- (UIEdgeInsets)insetsWithoutIdentifiers:(NSArray*)identifiers;

@property (nonatomic, retain) NSMutableDictionary* insetCollection;

@end
