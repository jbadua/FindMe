//
//  GroupMapViewController.h
//  FindMe
//
//  Created by Jason Badua on 6/2/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMaps/GoogleMaps.h>

@interface GroupMapViewController : UIViewController <GMSMapViewDelegate>

@property (nonatomic, copy) NSString *groupObjectId;
@property (nonatomic, strong) NSNumber *markerLatitude;
@property (nonatomic, strong) NSNumber *markerLongitude;

@end
