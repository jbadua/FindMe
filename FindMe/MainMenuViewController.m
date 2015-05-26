//
//  MainMenuViewController.m
//  FindMe
//
//  Created by Daniel Legler on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AddFriendsTableViewController.h"

#import <Parse/Parse.h>

@implementation MainMenuViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Navigation

- (IBAction)addFriends:(UIStoryboardSegue*)sender {
    AddFriendsTableViewController *sourceViewController = sender.sourceViewController;
    NSArray *users = sourceViewController.users;
    NSArray *selectedRows = sourceViewController.indexPathsForSelectedRows;

    for (NSIndexPath *selectedRow in selectedRows) {
        NSInteger selectedUserIndex = selectedRow.row;
        PFUser *friendUser = users[selectedUserIndex];
        PFObject *friend = [PFObject objectWithClassName:@"Friends"];
        friend[@"a"] = [PFUser currentUser].objectId;
        friend[@"b"] = friendUser.objectId;
        [friend saveInBackground];

        // Save friends in both directions
        PFObject *friend2 = [PFObject objectWithClassName:@"Friends"];
        friend2[@"a"] = friendUser.objectId;
        friend2[@"b"] = [PFUser currentUser].objectId;
        [friend2 saveInBackground];
    }
}

@end
