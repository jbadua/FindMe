//
//  ViewGroupsTableViewController.m
//  FindMe
//
//  Created by Jason Badua on 5/28/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "ViewGroupsTableViewController.h"
#import "GroupMapViewController.h"

#import <Parse/Parse.h>

@interface ViewGroupsTableViewController ()

@property (nonatomic) NSIndexPath *indexPath;

@end

@implementation ViewGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.definesPresentationContext = YES;

    //self.tableView.allowsMultipleSelectionDuringEditing = YES;
    //[self.tableView setEditing:NO animated:YES];

    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery whereKey:@"members" containsAllObjectsInArray:@[[PFUser currentUser].objectId]];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (!error) {
            NSMutableArray *groupsTemp = [[NSMutableArray alloc] initWithCapacity:groups.count];
            for (PFObject *group in groups) {
                [groupsTemp addObject:group];
            }
            self.groups = groupsTemp;
            [self.tableView reloadData]; // data may be loaded after the view
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    PFObject *group = self.groups[indexPath.row];
    cell.textLabel.text = group[@"groupName"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.indexPath = indexPath;
    [self performSegueWithIdentifier:@"groupSelected" sender:self];
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
    GroupMapViewController *destination = (GroupMapViewController *)segue.destinationViewController;
    PFObject *selectedGroup = self.groups[self.indexPath.row];
    destination.groupObjectId = selectedGroup.objectId;
}

@end
