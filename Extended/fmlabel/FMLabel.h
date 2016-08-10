#import <UIKit/UIKit.h>

typedef enum {
	FMLabelImagePlacementHorizontalStickToText = 0,
	FMLabelImagePlacementHorizontalStickToBorder = 1,
	
	FMLabelImagePlacementVerticalOnText = 64,
	FMLabelImagePlacementVerticalMiddle = 384, // default
	FMLabelImagePlacementVerticalTop = 128,
	FMLabelImagePlacementVerticalBottom = 256,
} FMLabelImagePlacement;

@interface FMLabel : UILabel {
	UILabel* realLabel;
}

@property (nonatomic,readonly) CGSize textSize;
@property (nonatomic,readonly) CGRect textRect;

@property (nonatomic,retain) UIImage* leftIconImage;
@property (nonatomic,readwrite) UIEdgeInsets leftIconSpacing;
@property (nonatomic,readwrite) FMLabelImagePlacement leftIconPlacement;
@property (nonatomic,readonly) UIImageView* leftImageView;

@property (nonatomic,retain) UIImage* rightIconImage;
@property (nonatomic,readwrite) UIEdgeInsets rightIconSpacing;
@property (nonatomic,readwrite) FMLabelImagePlacement rightIconPlacement;
@property (nonatomic,readonly) UIImageView* rightImageView;

@property (nonatomic,readwrite) BOOL shadowAppliesToImages;
@property (nonatomic,readwrite) BOOL colorizeImages;

@property (nonatomic,readwrite) UIEdgeInsets padding;

@end
