//
//  MapViewController.m
//  FindMe
//
//  Created by Jason Badua on 4/20/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "MapViewController.h"
#import "AddMarkerViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface MapViewController ()

@end

@implementation MapViewController {
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
    // TODO: Change 100.0 top padding to a scaled number based on the size of the view
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

#pragma mark - Navigation

- (IBAction)addNewMarker:(UIStoryboardSegue*)sender {
    AddMarkerViewController *sourceViewController = sender.sourceViewController;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = mapView_.myLocation.coordinate;
    marker.title = sourceViewController.markerTitle.text;
    marker.snippet = sourceViewController.markerSnippet.text;
    marker.map = mapView_;
    
    PFObject *textMarker = [PFObject objectWithClassName:@"TextMarker"];
    textMarker[@"Title"] = marker.title;
    textMarker[@"Snippet"] = marker.snippet;
    textMarker[@"Latitude"] = [NSNumber numberWithDouble:marker.position.latitude];
    textMarker[@"Longitude"] = [NSNumber numberWithDouble:marker.position.longitude];
    [textMarker saveInBackground];
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
