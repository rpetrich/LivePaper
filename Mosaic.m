//
//  ZZViews.m
//  yahyah
//
//  Created by Dan Zimmerman on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Mosaic.h"
#import <QuartzCore/QuartzCore.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>

@interface SBWallpaperView (adsf)
- (id)uncomposedImage;
@end

static CGImageRef backupImage = NULL;

@implementation MPMosaicView


- (void)updateTheLayers
{
	float dw = self.frame.size.width;
	float dh = self.frame.size.height;
	
	SBWallpaperView *view = [[objc_getClass("SBUIController") sharedInstance] wallpaperView];
	
	UIImage *image;
	
	if ([view respondsToSelector:@selector(uncomposedImage)]) {
		
		image = [view uncomposedImage];
		
	} else {
		
		image = [(UIImageView *)view image];
		
	}
	
	CGImageRef zImage = [image CGImage];
	
	if (zImage) {
		if (backupImage) {
			CGImageRelease(backupImage);
		}
		backupImage = CGImageCreateCopy(zImage);
	} else {
		zImage = backupImage;
	}
		
	for (int i = 0; i <dh/sizeHeight; i++) {
		
		for (int j = 0; j < dw/sizeWidth; j++) {
			
			CALayer *alayer = [CALayer layer];
			
			alayer.contents = (id)zImage;
			
			alayer.contentsRect = CGRectMake(j*sizeWidth/dw, i*sizeHeight/dh, sizeWidth/dw, sizeHeight/dh);
			
			float percent = (arc4random() % 41);
			
			float howLess = percent / 100.0f;
			
			float howLessWidth = howLess*sizeWidth;
			
			float howLessHeight = howLess*sizeHeight;
			
			alayer.frame = CGRectMake(j*sizeWidth, i*sizeHeight, sizeWidth-howLessWidth, sizeHeight-howLessHeight);
			
			[[self layer] addSublayer:alayer];
			
			CABasicAnimation *zAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
			
			zAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
			
			float ran = (((arc4random() % 11) / 10.0f) + 0.01f);
			
			zAnimation.toValue = [NSNumber numberWithFloat:1.0f+howLess + ran];
			
			float durat = (((arc4random() % 4001) / 100) + 2.0f);
			
			zAnimation.duration = durat;
			zAnimation.removedOnCompletion=NO;
			zAnimation.repeatCount = HUGE_VALF;
			zAnimation.autoreverses = YES;
			
			[alayer addAnimation:zAnimation forKey:@"transform"];
			
		}
		
	}
}

- (void)didMoveToWindow
{
	if (!self.window) {
		
		self.layer.sublayers = nil;
		
	} else {
				
		NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.thezimm.livepaper.mosaicpaper.plist"] ?: [[NSDictionary alloc] init];
		
		self.backgroundColor = [UIColor performSelector:NSSelectorFromString([prefs objectForKey:@"bgcolor"] ? : @"blackColor")];
		
		sizeWidth = [prefs objectForKey:@"tilewidth"] ? [[prefs objectForKey:@"tilewidth"] floatValue] : 80.0f;
		sizeHeight = [prefs objectForKey:@"tileheight"] ? [[prefs objectForKey:@"tileheight"] floatValue] : 80.0f;
		
		[prefs release];
		
		[self updateTheLayers];
		
	}
}

@end
