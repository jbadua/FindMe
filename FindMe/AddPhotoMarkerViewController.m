//
//  AddPhotoMarkerViewController.m
//  FindMe
//
//  Created by Anthony Rivera on 5/19/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "AddPhotoMarkerViewController.h"

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
    [self performSegueWithIdentifier:@"unwindToMapViewController" sender:self];
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
    NSLog(@"Delegate");
   // self.imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end


