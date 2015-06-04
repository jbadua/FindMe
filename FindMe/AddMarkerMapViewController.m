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
    CGSize scaledImageSize_;
    GMSMapView *mapView_;
    GMSMarker *marker_;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    scaledImageSize_ = CGSizeMake(25, 25);
    
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
    [self displayExistingMarkers:[PFUser currentUser].objectId];
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

- (void)displayExistingMarkers:(NSString *)creator {
    PFQuery *textMarkerQuery = [PFQuery queryWithClassName:@"TextMarker"];
    [textMarkerQuery whereKey:@"createdBy" equalTo:creator];
    [textMarkerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
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

    PFQuery *photoMarkerQuery = [PFQuery queryWithClassName:@"PhotoMarker"];
    [photoMarkerQuery whereKey:@"createdBy" equalTo:creator];
    [photoMarkerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
                // Coordinates stored as NSNumbers in Parse
                NSNumber *markerLatitude = (NSNumber *)object[@"latitude"];
                NSNumber *markerLongitude = (NSNumber *)object[@"longitude"];
                CLLocationCoordinate2D markerPosition;
                markerPosition.latitude = markerLatitude.doubleValue;
                markerPosition.longitude = markerLongitude.doubleValue;

                PFFile *imageFile = object[@"imageFile"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];

                        GMSMarker *marker = [[GMSMarker alloc] init];
                        marker.title = object[@"title"];
                        marker.snippet = object.objectId;
                        marker.icon = [self imageWithImage:image
                                              scaledToSize:scaledImageSize_];
                        marker.position = markerPosition;
                        marker.map = mapView_;
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Image utilities

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // In next line, pass 0.0 to use the current device's pixel scaling factor
    // (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
        self.markerPosition = location.coordinate;
        
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
    NSLog(@"Latitude: %f, Longitude: %f", marker.position.latitude, marker.position.longitude);
}

@end
