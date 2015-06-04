//
//  GroupMapViewController.m
//  FindMe
//
//  Created by Jason Badua on 6/2/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "GroupMapViewController.h"
#import "AddGroupMarkerMapViewController.h"
#import "AddMarkerViewController.h"
#import "AddMarkerMapViewController.h"
#import "AddPhotoMarkerViewController.h"
#import "ViewPhotoMarkerViewController.h"

#import <Parse/Parse.h>

@interface GroupMapViewController ()

@property (nonatomic, strong) GMSMarker *lastPhotoMarker;
// Used to send tapped photoMarker's objectID to ViewPhotoMarkerViewController
@property (nonatomic, copy) NSString *photoMarkerObjectId;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *friendMarkers;

@end

@implementation GroupMapViewController {
    BOOL firstLocationUpdate_;
    CGSize scaledImageSize_;
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    scaledImageSize_ = CGSizeMake(25, 25);
    self.friendMarkers = [[NSMutableArray alloc] init];
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
    [self displayExistingMarkers:self.groupObjectId];
    [self getGroupMemberLocations];

    [NSTimer scheduledTimerWithTimeInterval:4.0f
                                     target:self
                                   selector:@selector(getGroupMemberLocations)
                                   userInfo:nil
                                    repeats:YES];

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
    }
}

#pragma mark - Marker Methods

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

- (void)deleteMarker:(GMSMarker *)marker byCreator:(NSString *)creator {
    // Remove marker from map
    marker.map = nil;

    // Remove marker from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"TextMarker"];
    [query whereKey:@"createdBy" equalTo:creator];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
                CLLocationCoordinate2D markerPosition = marker.position;

                NSNumber *markerLatitude = (NSNumber *)object[@"latitude"];
                NSNumber *markerLongitude = (NSNumber *)object[@"longitude"];

                // TODO: change to query constraints
                if (markerPosition.longitude == markerLongitude.doubleValue
                    && markerPosition.latitude == markerLatitude.doubleValue){
                    [object deleteInBackground];
                }

            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - Navigation

- (IBAction)addNewMarker:(UIStoryboardSegue *)sender {
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
    textMarker[@"createdBy"] = self.groupObjectId;
    [textMarker saveInBackground];
}

- (IBAction)addNewPhotoMarker:(UIStoryboardSegue *)sender {
    AddPhotoMarkerViewController *sourceViewController = sender.sourceViewController;
    NSArray *childViewControllers = sourceViewController.childViewControllers;
    AddMarkerMapViewController *childViewController = childViewControllers[0];

    NSData *imageData = UIImagePNGRepresentation(sourceViewController.selectedImage);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    CLLocationCoordinate2D markerPosition = childViewController.markerPosition;

    PFObject *photoMarker = [PFObject objectWithClassName:@"PhotoMarker"];
    photoMarker[@"title"] = @"Photo";
    photoMarker[@"imageFile"] = imageFile;
    photoMarker[@"latitude"] = [NSNumber numberWithDouble:markerPosition.latitude];
    photoMarker[@"longitude"] = [NSNumber numberWithDouble:markerPosition.longitude];
    photoMarker[@"createdBy"] = self.groupObjectId;
    // GMSMarker created after photoMarker is saved to get objectId
    [photoMarker saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.title = photoMarker[@"title"];
        marker.snippet = photoMarker.objectId;
        marker.icon = [self imageWithImage:sourceViewController.selectedImage
                              scaledToSize:scaledImageSize_];
        marker.position = childViewController.markerPosition;
        marker.map = mapView_;
    }];
}

- (IBAction)deletePhotoMarker:(UIStoryboardSegue *)sender {
    // Remove marker from map
    self.lastPhotoMarker.map = nil;

    // Remove marker from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoMarker"];
    [query whereKey:@"objectId" equalTo:self.photoMarkerObjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
                CLLocationCoordinate2D markerPosition = self.lastPhotoMarker.position;

                NSNumber *markerLatitude = (NSNumber *)object[@"latitude"];
                NSNumber *markerLongitude = (NSNumber *)object[@"longitude"];

                // TODO: change to query constraints
                if (markerPosition.longitude == markerLongitude.doubleValue
                    && markerPosition.latitude == markerLatitude.doubleValue){
                    [object deleteInBackground];
                }

            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        ViewPhotoMarkerViewController *destination =
        (ViewPhotoMarkerViewController *)segue.destinationViewController;
        destination.photoMarkerObjectId = self.photoMarkerObjectId;
    } else if ([segue.identifier isEqualToString:@"addGroupMarker"]) {
        UITabBarController *destination = segue.destinationViewController;
        AddMarkerViewController *child = destination.childViewControllers[0];
        child.groupObjectId = self.groupObjectId;
        AddPhotoMarkerViewController *otherChild = destination.childViewControllers[1];
        otherChild.groupObjectId = self.groupObjectId;
    }
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

#pragma mark - GMSMapViewDelegate Methods

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    // Photos have a photo as it's title
    if ([marker.title isEqualToString:@"Photo"]) {
        self.lastPhotoMarker = marker;
        // Photos have the photo objectId as the snippet
        self.photoMarkerObjectId = marker.snippet;
        [self performSegueWithIdentifier:@"showPhoto" sender:self];
        return YES;
    } else {
        return NO;
    }

}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if ([marker.snippet containsString:@"Last Updated:"]) {
        // Users shouldn't be deleted from mapView
        return;
    }
    UIAlertController* alert =
    [UIAlertController alertControllerWithTitle:@"Delete Marker"
                                        message:@"Would you like to delete this marker?"
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction =
    [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               [self deleteMarker:marker byCreator:self.groupObjectId];
                               marker.map = nil;
                           }];

    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];

    [alert addAction:defaultAction];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];

}



#pragma mark - FriendMarker Methods

- (void)getGroupMemberLocations {
    // If query for friends already done, just fetch latest data
    if (self.friendMarkers) {
        for (GMSMarker *marker in self.friendMarkers) {
            marker.map = nil;
        }
        [self.friends removeAllObjects];
        [self.friendMarkers removeAllObjects];
    }

    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery whereKey:@"objectId" equalTo:self.groupObjectId];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // NSLog(@"Successfully retrieved %lu friends.", (unsigned long)objects.count);
            for (NSString *userObjectId in objects[0][@"members"]){
                // Don't display current user as a friendMarker
                if ([userObjectId isEqualToString:[PFUser currentUser].objectId]) {
                    continue;
                }
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"objectId" equalTo:userObjectId];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        // The find succeeded.
                        // NSLog(@"Successfully retrieved %lu friends test.", (unsigned long)objects.count);
                        // Do something with the found objects
                        for (PFObject *object in objects) {
                            [self.friends addObject:object];
                            // Coordinates stored as NSNumbers in Parse
                            NSNumber *markerLatitude = (NSNumber *)object[@"latitude"];
                            NSNumber *markerLongitude = (NSNumber *)object[@"longitude"];
                            CLLocationCoordinate2D markerPosition;
                            markerPosition.latitude = markerLatitude.doubleValue;
                            markerPosition.longitude = markerLongitude.doubleValue;
                            NSDate *updatedAt = [object updatedAt];
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                            [dateFormat setDateFormat:@"MMM d, h:mm a"];

                            GMSMarker *marker = [[GMSMarker alloc] init];
                            marker.title = object[@"username"];
                            marker.snippet = [NSString stringWithFormat:@"Last Updated: %@", [dateFormat stringFromDate:updatedAt]];
                            marker.position = markerPosition;
                            marker.map = mapView_;
                            marker.icon = [UIImage imageNamed:@"friend_marker.png"];
                            [self.friendMarkers addObject:marker];
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
