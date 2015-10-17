//
//  SignInViewController.m
//  FindMe
//
//  Created by Jason Badua on 10/16/15.
//  Copyright © 2015 Jason Badua. All rights reserved.
//

#import "SignInViewController.h"

#import <Parse/Parse.h>

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.username setReturnKeyType:UIReturnKeyDone];
    [self.userPassword setReturnKeyType:UIReturnKeyDone];

    self.username.delegate = self;
    self.userPassword.delegate = self;

    self.userPassword.secureTextEntry = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displaySignInError:(NSError *)error {
    NSString *alertTitle = @"Sign In Failed";
    NSString *alertMessage = [error userInfo][@"error"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         NSLog(@"OK action");
                                                     }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)signInUser:(id)sender {
    [PFUser logInWithUsernameInBackground:self.username.text password:self.userPassword.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                            [self performSegueWithIdentifier:@"userSignedIn" sender:nil];
                                        } else {
                                            // The login failed. Check error to see why.
                                            [self displaySignInError:error];
                                        }
                                    }];
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
