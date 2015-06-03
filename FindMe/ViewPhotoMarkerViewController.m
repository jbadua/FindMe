//
//  ViewPhotoMarkerViewController.m
//  FindMe
//
//  Created by Jason Badua on 6/3/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "ViewPhotoMarkerViewController.h"

#import <Parse/Parse.h>

@interface ViewPhotoMarkerViewController ()

@end

@implementation ViewPhotoMarkerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFQuery *photoMarkerQuery = [PFQuery queryWithClassName:@"PhotoMarker"];
    NSLog(@"View Photo");
    NSLog(@"View Photo Object Id: %@", self.photoMarkerObjectId);
    [photoMarkerQuery whereKey:@"objectId" equalTo:self.photoMarkerObjectId];
    [photoMarkerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            for (PFObject *object in objects) {
                PFFile *imageFile = object[@"imageFile"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        self.imageView.image = image;
                    }
                }];

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
