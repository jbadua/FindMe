//
//  MainMenuViewController.h
//  FindMe
//
//  Created by Daniel Legler on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface MainMenuViewController : UIViewController <GMSMapViewDelegate>

@property(nonatomic,retain) CLLocationManager *locationManager;


@end
