//
//  AddMarkerMapViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

// TODO: Subclass this and MapViewController from common super class

#import "AddMarkerMapViewController.h"

#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface AddMarkerMapViewController ()

@end

@implementation AddMarkerMapViewController {
    BOOL firstLocationUpdate_;
    GMSMapView *mapView_;
    GMSMarker *marker_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    [mapView_ setMinZoom:15 maxZoom:20];
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = mapView_;
    mapView_.delegate = self;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    [self addExistingMarkers];
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

- (void)addExistingMarkers {
    PFQuery *query = [PFQuery queryWithClassName:@"TextMarker"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu Markers.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);

                // Coordinates stored as NSNumbers in Parse
                NSNumber *markerLatitude = (NSNumber *)object[@"latitude"];
                NSNumber *markerLongitude = (NSNumber *)object[@"longitude"];
                CLLocationCoordinate2D markerPosition;
                markerPosition.latitude = markerLatitude.doubleValue;
                markerPosition.longitude = markerLongitude.doubleValue;

                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.title = object[@"title"];
                marker.snippet = object[@"snippet"];
                marker.position = markerPosition;
                marker.map = mapView_;
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
                                                         zoom:15];
        
        // Places marker on current location
        marker_ = [[GMSMarker alloc] init];
        marker_.position = mapView_.myLocation.coordinate;
        marker_.draggable = YES;
        marker_.map = mapView_;
    }
}

#pragma mark - GMSMapViewDelegate Methods

// Disables marker info window
// Marker is only used to get location for the new marker
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (marker.draggable) {
        return YES;
    } else {
        return NO;
    }

}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    self.markerPosition = marker.position;
}

@end
