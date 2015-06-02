//
//  AddFriendsTableViewController.h
//  FindMe
//
//  Created by Jason Badua on 5/18/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendsTableViewController : UITableViewController

@property (nonatomic, copy) NSArray *users;
@property (nonatomic, copy) NSArray *indexPathsForSelectedRows;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;

@end
