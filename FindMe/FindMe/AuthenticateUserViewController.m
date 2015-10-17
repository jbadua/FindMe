//
//  AuthenticateUserViewController.m
//  FindMe
//
//  Created by Jason Badua on 10/16/15.
//  Copyright © 2015 Jason Badua. All rights reserved.
//

#import "AuthenticateUserViewController.h"

#import <Parse/Parse.h>

@interface AuthenticateUserViewController ()

@end

@implementation AuthenticateUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self performSegueWithIdentifier:@"curentUserAuthenticated" sender:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
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
