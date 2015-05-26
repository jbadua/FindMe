//
//  AuthenticateUserViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/15/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "AuthenticateUserViewController.h"

#import <Parse/Parse.h>

@interface AuthenticateUserViewController ()

@end

@implementation AuthenticateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // User logout used for testing
    //[PFUser logOut];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self performSegueWithIdentifier:@"curentUserAuthenticated" sender:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
