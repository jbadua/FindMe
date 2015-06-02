//
//  CreateGroupTableViewController.h
//  FindMe
//
//  Created by Jason Badua on 5/28/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupTableViewController : UITableViewController

@property (nonatomic) UITextField *groupName;
@property (nonatomic) UIDatePicker *groupEndDate;
@property (nonatomic, copy) NSArray *users;
@property (nonatomic, copy) NSArray *indexPathsForSelectedRows;

@end
