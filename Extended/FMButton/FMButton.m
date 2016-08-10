//
//  FMButton.m
//
//

#import "FMButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation FMButton

- (void)dealloc {
    [bgColors[0] release];
    [bgColors[1] release];
    [bgColors[2] release];
    [bgColors[3] release];
	self.sideData = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
	[bgColors[0] autorelease]; bgColors[0] = [backgroundColor retain];
	[super setBackgroundColor:backgroundColor];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
	char index = 0;
	if (state==UIControlStateHighlighted) index = 1;
	else if (state==UIControlStateSelected) index = 2;
	else if (state==UIControlStateDisabled) index = 3;
	[bgColors[index] autorelease]; bgColors[index] = [backgroundColor retain];
	[self updateBackgroundColor];
}
- (void)updateBackgroundColor {
	if (!self.enabled && bgColors[3]) {
		[super setBackgroundColor:bgColors[3]];
		return;
	}
	if (self.highlighted && bgColors[1]) {
		[super setBackgroundColor:bgColors[1]];
		return;
	}
	if (self.selected && bgColors[2]) {
		[super setBackgroundColor:bgColors[2]];
		return;
	}
	[super setBackgroundColor:bgColors[0]];
}
- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self updateBackgroundColor];
}
- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	[self updateBackgroundColor];
}
- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self updateBackgroundColor];
}

- (UIImageView *)imageView {
	if (!imageView) {
		imageView = [UIImageView.alloc initWithFrame:self.bounds].autorelease;
		imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
		imageView.alpha = 1.0;
		[self addSubview:imageView];
	}
	return imageView;
}

- (void)setCustomStyle:(NSString *)customStyle {
	[_customStyle release]; _customStyle = [customStyle retain];
	if (!customStyle) return;
	if ([customStyle isEqualToString:@""]) {
		self.layer.cornerRadius = 4.0;
		self.layer.borderWidth = 1.0;
		self.layer.borderColor = UIColor.blackColor.CGColor;
		self.titleColor = UIColor.blackColor;
		[self setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
		[self setBackgroundColor:UIColor.grayColor forState:UIControlStateHighlighted];
	}
}

- (NSString *)title { return [self titleForState:UIControlStateNormal]; }
- (void)setTitle:(NSString *)title { [self setTitle:title forState:UIControlStateNormal]; }
- (UIColor *)titleColor { return [self titleColorForState:UIControlStateNormal]; }
- (void)setTitleColor:(UIColor *)titleColor { [self setTitleColor:titleColor forState:UIControlStateNormal]; }

@end
