//
//  CreateGroupDescriptionViewController.m
//  FindMe
//
//  Created by Jason Badua on 6/1/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "CreateGroupDescriptionViewController.h"
#import "CreateGroupTableViewController.h"

@interface CreateGroupDescriptionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UIDatePicker *groupEndDate;

@end

@implementation CreateGroupDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.groupEndDate.minimumDate =
        [[ NSDate alloc ] initWithTimeIntervalSinceNow: (NSTimeInterval) 0 ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CreateGroupTableViewController *destination = [segue destinationViewController];
    destination.groupName = self.groupName;
    destination.groupEndDate = self.groupEndDate;
}

@end
