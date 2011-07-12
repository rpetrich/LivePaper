#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LPFaderView : UIView
@end

@implementation LPFaderView

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		animation.fromValue = [NSNumber numberWithFloat:0.0f];
		animation.toValue = [NSNumber numberWithFloat:0.5f];
		animation.removedOnCompletion = NO;
		animation.duration = 2.0;
		animation.repeatCount = HUGE_VALF;
		animation.autoreverses = YES;
		[self.layer addAnimation:animation forKey:@"opacity"];
	}
	return self;
}

@end
