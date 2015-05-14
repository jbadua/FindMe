//
//  AddMarkerMapViewController.h
//  FindMe
//
//  Created by Jason Badua on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AddMarkerMapViewController : UIViewController <GMSMapViewDelegate>

@property CLLocationCoordinate2D markerPosition;

@end
