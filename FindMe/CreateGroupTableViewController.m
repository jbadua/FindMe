//
//  CreateGroupTableViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/28/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "CreateGroupTableViewController.h"
#import "ViewGroupsTableViewController.h"

#import <Parse/Parse.h>

@interface CreateGroupTableViewController ()

@end

@implementation CreateGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.definesPresentationContext = YES;

    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];

    PFQuery *friendsQuery = [PFQuery queryWithClassName:@"Friends"];
    [friendsQuery whereKey:@"a" equalTo:[PFUser currentUser].objectId];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Create a user query for each friend
            NSMutableArray *userQueries = [[NSMutableArray alloc] init];
            for (PFObject *object in objects) {
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"objectId" equalTo:object[@"b"]];
                [userQueries addObject:userQuery];
            }

            PFQuery *query = [PFQuery orQueryWithSubqueries:userQueries];
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error2) {
                if (!error) {
                    NSMutableArray *usersTemp = [[NSMutableArray alloc] initWithCapacity:objects.count];
                    for (PFUser *user in users) {
                        [usersTemp addObject:user];
                    }
                    self.users = usersTemp;
                    [self.tableView reloadData]; // data may be loaded after the view
                } else {
                    NSLog(@"Error: %@ %@", error2, [error userInfo]);
                }
            }];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (void)createGroup {
    NSMutableArray *usersInGroup = [[NSMutableArray alloc] initWithCapacity:self.users.count];

    // By convention, the user that creates the group occurs first in the array
    [usersInGroup addObject:[PFUser currentUser].objectId];
    for (NSIndexPath *indexPath in self.indexPathsForSelectedRows) {
        NSInteger selectedUserIndex = indexPath.row;
        PFUser *selectedUser = self.users[selectedUserIndex];
        [usersInGroup addObject:selectedUser.objectId];
    }


    PFObject *group = [PFObject objectWithClassName:@"Group"];
    group[@"members"] = usersInGroup;
    group[@"groupName"] = self.groupName.text;
    group[@"endDate"] = self.groupEndDate.date;
    [group saveInBackground];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    PFUser *user = self.users[indexPath.row];
    cell.textLabel.text = user[@"username"];

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     self.indexPathsForSelectedRows = [self.tableView indexPathsForSelectedRows];

     if ([segue.identifier isEqualToString:@"newGroupCreated"]) {
         [self createGroup];
         [self.navigationController popViewControllerAnimated:YES];
     }
 }

@end
