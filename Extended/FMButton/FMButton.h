//
//  FMButton.h
//
//

#import <UIKit/UIKit.h>

@interface FMButton : UIButton {
	UIColor *bgColors[4];
	UIImageView* imageView;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@property (nonatomic,retain) NSString* customStyle;

@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) UIColor* titleColor;
@property (nonatomic,retain) id sideData;

@end
