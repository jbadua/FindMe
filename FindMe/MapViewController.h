//
//  MapViewController.h
//  FindMe
//
//  Created by Jason Badua on 4/20/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController <GMSMapViewDelegate>

- (void)displayExistingMarkers:(NSString *)creator;
- (void)deleteMarker:(GMSMarker *)marker byCreator:(NSString *)creator;

@end
