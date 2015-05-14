//
//  AddMarkerViewController.h
//  FindMe
//
//  Created by Jason Badua on 5/12/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;


@interface AddMarkerViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *markerTitle;
@property (weak, nonatomic) IBOutlet UITextView *markerSnippet;

@end
