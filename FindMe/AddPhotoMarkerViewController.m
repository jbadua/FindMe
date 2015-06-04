//
//  AddPhotoMarkerViewController.m
//  FindMe
//
//  Created by Anthony Rivera on 5/19/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "AddPhotoMarkerViewController.h"
#import "AddGroupMarkerMapViewController.h"
#import "GroupMapViewController.h"
#import "MapViewController.h"

@implementation AddPhotoMarkerViewController

@synthesize imageView;
@synthesize selectedImage;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIBarButtonItem *rightButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(addNewPhotoMarker:)];
    self.tabBarController.navigationItem.rightBarButtonItem = rightButton;
}

- (IBAction)addNewPhotoMarker:(id)sender {
    if (self.groupObjectId) {
        [self performSegueWithIdentifier:@"unwindToGroupMapViewController" sender:self];
    } else {
        [self performSegueWithIdentifier:@"unwindToMapViewController" sender:self];
    }
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"Select where to add photo marker from:"
                                    delegate:self
                           cancelButtonTitle:@"Cancel"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"Take Photo", @"Select from Photo Library", nil];
    
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self takePhoto:nil];
    }
    else if (buttonIndex == 1) {
        [self selectPhoto:nil];
    }
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    self.selectedImage = image;
    self.imageView.image = self.selectedImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
   // self.imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"embedGroupMarkerMap"]) {
        AddGroupMarkerMapViewController *child = segue.destinationViewController;
        NSLog(@"AddPhotoMarkerView: %@", self.groupObjectId);
        child.groupObjectId = self.groupObjectId;
    } else if ([segue.identifier isEqualToString:@"unwindToGroupMapViewController"]) {
        AddGroupMarkerMapViewController *child = self.childViewControllers[0];
        GroupMapViewController *destination = segue.destinationViewController;
        destination.markerLatitude = [NSNumber numberWithDouble:child.markerPosition.latitude];
        destination.markerLatitude = [NSNumber numberWithDouble:child.markerPosition.longitude];
    } else if ([segue.identifier isEqualToString:@"unwindToGroupMapViewController"]) {
        AddGroupMarkerMapViewController *child = self.childViewControllers[0];
        MapViewController *destination = segue.destinationViewController;
        destination.markerLatitude = [NSNumber numberWithDouble:child.markerPosition.latitude];
        destination.markerLatitude = [NSNumber numberWithDouble:child.markerPosition.longitude];
    }
}

@end


