//
//  ViewPhotoMarkerViewController.h
//  FindMe
//
//  Created by Jason Badua on 6/3/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewPhotoMarkerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSString *photoMarkerObjectId;

@end
