//
//  ZZViews.m
//  yahyah
//
//  Created by Dan Zimmerman on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Map.h"

@interface MKMapView (asdf)
-(void)_goToUserLocation:(BOOL)userLocation shouldZoom:(BOOL)zoom;
-(void)_zoomToNextLevel:(int)nextLevel tapCentroid:(CGPoint)centroid;
-(void)_setZoomLevel:(float)level duration:(double)duration;
- (float)_zoomLevel;
- (void)goToUserLocation;
- (void)resumeUserLocationUpdates;
- (void)setUserTrackingMode:(int)adsf animated:(BOOL)asdf;
@end

@implementation MPMapPaperView

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]) != nil) {
		
		self.delegate = self;
		
		[self setShowsUserLocation:YES];
		
	}
	
	return self;
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
	NSLog(@"IM UPDATING THE LOCATION");
	[self performSelector:@selector(resumeUserLocationUpdates) withObject:nil afterDelay:0.4f];
	[self performSelector:@selector(setShowsUserLocation:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.41f];
	if ([self respondsToSelector:@selector(setUserTrackingMode:animated:)])
		[self setUserTrackingMode:1 animated:YES];
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
	NSLog(@"I STOPPED UPDATING THE MAP LOCATION");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	[self setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	NSLog(@"I FAILED TO UPDATE MAP: %@", error);
}

- (void)didMoveToWindow
{
	if (!self.window) {
		
		[rec1 removeTarget:nil action:NULL];
		[rec11 removeTarget:nil action:NULL];
		[rec111 removeTarget:nil action:NULL];
		
		[rec1.view removeGestureRecognizer:rec1];
		[rec11.view removeGestureRecognizer:rec11];
		[rec111.view removeGestureRecognizer:rec11];
		[rec1 release];
		[rec11 release];
		[rec111 release];
		
	} else {
		
		
		rec1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
		rec1.numberOfTapsRequired = 2;
		rec11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
		rec11.numberOfTouchesRequired = 2;
		rec111 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(center:)];
		rec111.numberOfTouchesRequired = 3;
		[self.window addGestureRecognizer:rec1];
		[self.window addGestureRecognizer:rec11];
		[self.window addGestureRecognizer:rec111];
		 
		
	}
}

- (void)zoom:(id)adsf
{
	[self _zoomToNextLevel:1 tapCentroid:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
}

- (void)center:(id)asdf
{
	[self setCenterCoordinate:self.userLocation.location.coordinate animated:YES];
}

@end
