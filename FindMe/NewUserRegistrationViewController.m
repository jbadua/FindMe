//
//  NewUserRegistrationViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/15/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "NewUserRegistrationViewController.h"

#import <Parse/Parse.h>

@interface NewUserRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UITextField *userConfirmPassword;

@end

@implementation NewUserRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userPassword.secureTextEntry = YES;
    self.userConfirmPassword.secureTextEntry = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                NSString *errorString = [error userInfo][@"error"];
                UIAlertController *alert = nil;
                // Show the errorString somewhere and let the user try again.
            }
        }];
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
