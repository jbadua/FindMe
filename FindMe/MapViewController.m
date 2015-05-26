//
//  MapViewController.m
//  FindMe
//
//  Created by Jason Badua on 4/20/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

// TODO: Subclass this and AddMarkerMapViewController from common super class

#import "MapViewController.h"
#import "AddMarkerViewController.h"
#import "AddMarkerMapViewController.h"

#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface MapViewController ()

@property (nonatomic, strong) NSArray *friends;

@end

@implementation MapViewController {
    BOOL firstLocationUpdate_;
    GMSMapView *mapView_;
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
    [self addExistingMarkers];
    [self getFriendsLocations];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                      target:self
                                                    selector:@selector(getFriendsLocations)
                                                    userInfo:nil
                                                     repeats:YES];
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

#pragma mark - Navigation

- (IBAction)addNewMarker:(UIStoryboardSegue*)sender {
    AddMarkerViewController *sourceViewController = sender.sourceViewController;
    NSArray *childViewControllers = sourceViewController.childViewControllers;
    AddMarkerMapViewController *childViewController = childViewControllers[0];
    
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.title = sourceViewController.markerTitle.text;
    marker.snippet = sourceViewController.markerSnippet.text;
    marker.position = childViewController.markerPosition;
    marker.map = mapView_;
    
    // Disable saving to parse while testing
    PFObject *textMarker = [PFObject objectWithClassName:@"TextMarker"];
    textMarker[@"title"] = marker.title;
    textMarker[@"snippet"] = marker.snippet;
    textMarker[@"latitude"] = [NSNumber numberWithDouble:marker.position.latitude];
    textMarker[@"longitude"] = [NSNumber numberWithDouble:marker.position.longitude];
    textMarker[@"createdBy"] = [PFUser currentUser].objectId;
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


#pragma mark - FriendMarker Methods
- (void)getFriendsLocations {
    
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery whereKey:@"a" equalTo:[PFUser currentUser].objectId];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.friends = objects;
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu friends.", (unsigned long)objects.count);
            
            for(PFObject *friend in self.friends){
                PFQuery *locationQuery = [PFUser query];
                [locationQuery whereKey:@"objectId" equalTo:friend[@"b"]];
                [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        NSLog(@"Successfully retrieved %lu friends test.", (unsigned long)objects.count);
                        // Do something with the found objects
                        for (PFObject *object in objects) {
                            NSLog(@"%@", object.objectId);
                            
                            // Coordinates stored as NSNumbers in Parse
                            NSNumber *markerLatitude = (NSNumber *)object[@"latitude"];
                            NSNumber *markerLongitude = (NSNumber *)object[@"longitude"];
                            CLLocationCoordinate2D markerPosition;
                            markerPosition.latitude = markerLatitude.doubleValue;
                            markerPosition.longitude = markerLongitude.doubleValue;
                            NSLog(@"Latitude: %f \n Longitude: %f",markerPosition.latitude,markerPosition.longitude);
                            
                            // TODO: Need to display the last time each person was online
                            GMSMarker *marker = [[GMSMarker alloc] init];
                            marker.title = object[@"username"];
                            marker.position = markerPosition;
                            marker.map = mapView_;
                            marker.icon = [UIImage imageNamed:@"friend_marker.png"];
                        }
                    } else {
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
     }];
}

    
         

@end
