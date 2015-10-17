//
//  SignUpViewController.m
//  FindMe
//
//  Created by Jason Badua on 10/16/15.
//  Copyright © 2015 Jason Badua. All rights reserved.
//

#import "SignUpViewController.h"

#import <Parse/Parse.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UITextField *userConfirmPassword;

@end

@implementation SignUpViewController

static NSString *const errorTitle = @"Sign Up Failed";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.username setReturnKeyType:UIReturnKeyDone];
    [self.userEmail setReturnKeyType:UIReturnKeyDone];
    [self.userPassword setReturnKeyType:UIReturnKeyDone];
    [self.userConfirmPassword setReturnKeyType:UIReturnKeyDone];

    self.username.delegate = self;
    self.userEmail.delegate = self;
    self.userPassword.delegate = self;
    self.userConfirmPassword.delegate = self;

    self.userPassword.secureTextEntry = YES;
    self.userConfirmPassword.secureTextEntry = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayAlertMessage:(NSString *)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)displayUserRegistrationError:(NSError *)error {
    NSString *alertMessage = [error userInfo][@"error"];
    [self displayAlertMessage:alertMessage];
}

- (IBAction)createNewUser:(id)sender {
    if ([self.userPassword.text isEqualToString:self.userConfirmPassword.text]) {
        PFUser *user = [PFUser user];
        user.username = self.username.text;
        user.password = self.userPassword.text;
        user.email = self.userEmail.text;

        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {   // Hooray! Let them use the app now.
                [self performSegueWithIdentifier:@"newUserCreated" sender:sender];
            } else {
                [self displayUserRegistrationError:error];
            }
        }];
    } else {
        NSString *alertMessage = @"Passwords do not match";
        [self displayAlertMessage:alertMessage];
    }
}

#pragma mark - UITextViewDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
