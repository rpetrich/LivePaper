//
//  ZZViews.m
//  yahyah
//
//  Created by Dan Zimmerman on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MosaicPrefs.h"

@implementation MPController
- (id)specifiers {
    if(_specifiers == nil) {
			// Loads specifiers from Name.plist from the bundle we're a part of.
        _specifiers = [[self loadSpecifiersFromPlistName:@"Mosaic" target:self] retain];
    }
    return _specifiers;
}

- (void)resetSettings
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PSSpecifier *spec;
	
	int a = 0;
	
	for (NSString *idd in [NSArray arrayWithObjects:@"tilewidth", @"tileheight", @"bgcolor",nil]) {
		
		spec = [self specifierForID:idd];
		
		[self setPreferenceValue:(a < 2 ? (id)[NSNumber numberWithFloat:80.0f] : (id)@"blackColor") specifier:spec];
		[spec setProperty:(a < 2 ? (id)[NSNumber numberWithFloat:80.0f] : (id)@"blackColor") forKey:idd];
		
		[self reloadSpecifierID:idd animated:YES];
		
		a++;
		
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[pool drain];
}

@end

