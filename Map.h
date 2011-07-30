//
//  ZZViews.h
//  yahyah
//
//  Created by Dan Zimmerman on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MPMapPaperView : MKMapView<MKMapViewDelegate> {
	UITapGestureRecognizer *rec1;
	UITapGestureRecognizer *rec11;
	UITapGestureRecognizer *rec111;
}
@end