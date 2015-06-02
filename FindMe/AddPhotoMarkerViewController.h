//
//  AddPhotoMarkerViewController.h
//  FindMe
//
//  Created by Anthony Rivera on 5/19/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AddPhotoMarkerViewController : UIViewController
    <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *selectedImage;

- (IBAction)showActionSheet:(id)sender;
- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;
- (void)actionSheet: (UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
