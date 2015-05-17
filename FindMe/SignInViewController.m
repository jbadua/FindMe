//
//  SignInViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/15/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
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

    self.userPassword.secureTextEntry = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInUser:(id)sender {
    [PFUser logInWithUsernameInBackground:self.username.text password:self.userPassword.text
                                    block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
            [self performSegueWithIdentifier:@"userSignedIn" sender:nil];
        } else {
            // The login failed. Check error to see why.
            // TODO: Show alert with error text
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
