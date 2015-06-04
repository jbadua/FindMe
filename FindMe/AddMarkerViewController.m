//
//  AddMarkerViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/12/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "AddMarkerViewController.h"
#import "AddMarkerMapViewController.h"

@interface AddMarkerViewController ()

@end

@implementation AddMarkerViewController {
    UIColor *placeholderTextColor_;
}

- (void)viewDidLoad {
    // A text view is a scroll view. iOS 7 will add a content offset automatically to scroll views,
    // as it assumes they will want to scroll up behind the nav bar and title bar.
    self.automaticallyAdjustsScrollViewInsets = NO;

    // Adds border to markerSnippet text view
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0
                                           green:204.0/255.0
                                            blue:204.0/255.0
                                           alpha:1.0];
    self.markerSnippet.layer.borderWidth = 0.5f;
    self.markerSnippet.layer.borderColor = [borderColor CGColor];
    self.markerSnippet.layer.cornerRadius = 8;
    
    // Adds placeholder text to markerSnippet text view
    placeholderTextColor_ = [UIColor colorWithRed:199.0/255.0
                                            green:199.0/255.0
                                             blue:204.0/255.0
                                            alpha:1.0];
    self.markerSnippet.textColor = placeholderTextColor_;
    self.markerSnippet.text = @"Description";
    self.markerSnippet.delegate = self;
    self.markerTitle.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIBarButtonItem *rightButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                      target:self
                                                      action:@selector(addNewMarker:)];
    self.tabBarController.navigationItem.rightBarButtonItem = rightButton;
}

- (IBAction)addNewMarker:(id)sender {
    [self performSegueWithIdentifier:@"unwindToMapViewController" sender:self];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - UITextViewDelegate Methods

#define markerSnippetLength 140

// Limits text length
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= markerSnippetLength;
}

// Removes placeholder text when user begins writing
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.markerSnippet.textColor == placeholderTextColor_) {
        self.markerSnippet.textColor = [UIColor blackColor];
        self.markerSnippet.text = @"";
    }
    return YES;
}

// Adds placeholder text if markerSnipper is empty
- (void)textViewDidChange:(UITextView *)textView {
    if (self.markerSnippet.text.length == 0) {
        self.markerSnippet.textColor = placeholderTextColor_;
        self.markerSnippet.text = @"Description";
        [self.markerSnippet resignFirstResponder];
    }
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
