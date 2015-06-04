//
//  AddGroupMarkerMapViewController.h
//  FindMe
//
//  Created by Jason Badua on 6/4/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AddGroupMarkerMapViewController : UIViewController <GMSMapViewDelegate>

@property (nonatomic, copy) NSString *groupObjectId;
@property CLLocationCoordinate2D markerPosition;

@end
