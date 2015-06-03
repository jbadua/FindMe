//
//  GroupMapViewController.m
//  FindMe
//
//  Created by Jason Badua on 6/2/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "GroupMapViewController.h"

#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface GroupMapViewController ()

@end

@implementation GroupMapViewController {
    BOOL firstLocationUpdate_;
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Overrides MapViewController's addExistingMarkers
- (void)addExistingMarkers {
    PFQuery *textMarkerQuery = [PFQuery queryWithClassName:@"TextMarker"];
    // TODO: objectIds are only unique per class. Change createdBy to lead with
    // "u" for user markers and "g" for group markers
    [textMarkerQuery whereKey:@"createdBy" equalTo:self.groupObjectId];
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
    [photoMarkerQuery whereKey:@"groupId" equalTo:self.groupObjectId];
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

                GMSMarker *marker = [[GMSMarker alloc] init];

                marker.title = object[@"title"];
                marker.icon = object[@"image"];
                marker.position = markerPosition;
                marker.map = mapView_;
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
