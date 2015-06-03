//
//  MainMenuViewController.m
//  FindMe
//
//  Created by Daniel Legler on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AddFriendsTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>



@implementation MainMenuViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [self.locationManager startUpdatingLocation];
    [self testTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Navigation

- (IBAction)addFriends:(UIStoryboardSegue *)sender {
    AddFriendsTableViewController *sourceViewController = sender.sourceViewController;
    NSArray *users = sourceViewController.users;
    NSArray *selectedRows = sourceViewController.indexPathsForSelectedRows;

    for (NSIndexPath *selectedRow in selectedRows) {
        NSInteger selectedUserIndex = selectedRow.row;
        PFUser *friendUser = users[selectedUserIndex];
        PFObject *friend = [PFObject objectWithClassName:@"Friends"];
        friend[@"a"] = [PFUser currentUser].objectId;
        friend[@"b"] = friendUser.objectId;
        [friend saveInBackground];

        // Save friends in both directions
        PFObject *friend2 = [PFObject objectWithClassName:@"Friends"];
        friend2[@"a"] = friendUser.objectId;
        friend2[@"b"] = [PFUser currentUser].objectId;
        [friend2 saveInBackground];
    }
}

- (void)testTimer{
    [NSTimer scheduledTimerWithTimeInterval:4.0
                                     target:self
                                   selector:@selector(getDeviceLocation)
                                   userInfo:nil
                                    repeats:YES];


}



- (void)getDeviceLocation
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //   The find succeeded.
            for (PFObject *object in objects) {
                NSNumber* newLatitude = [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude];
                NSNumber* newLongitude = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
                NSLog(@"New Longitude: %@", newLongitude);
                NSLog(@"New Latitude: %@", newLatitude);

                [object setObject:newLatitude forKey:@"latitude"];
                [object setObject:newLongitude forKey:@"longitude"];
                [object saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    
}

@end