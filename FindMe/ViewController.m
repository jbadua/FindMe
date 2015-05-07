//
//  ViewController.m
//  FindMe
//
//  Created by Jason Badua on 4/20/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController ()

@end

@implementation ViewController {
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];

    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;


    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    self.view = mapView_;
    mapView_.delegate = self;
    
    // Adds padding to move compassButton into the display
    // TODO: Change 100.0 top padding to a scaled number based on the view
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 0.0, 0.0, 0.0);
    mapView_.padding = mapInsets;

    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
        // Place marker at my location for testing
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = mapView_.myLocation.coordinate;
        marker.title = @"Photo";
        marker.snippet = @"1234567890";
        marker.map = mapView_;
    }
}

#pragma mark - GMSMapViewDelegate Methods

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    // Photos have a photo as it's title
    if ([marker.title isEqualToString:@"Photo"]) {
        // Photos have the photo name as the snippet
        NSLog(@"%@", marker.snippet);
        return YES;
    } else {
        return NO;
    }
    
}

@end
