//
//  ContactsTableViewController.m
//  FindMe
//
//  Created by Daniel Legler on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.


#import "ContactsTableViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@import MessageUI;


enum TableRowSelected
{
    kUIDisplayPickerRow = 0,
    kUICreateNewContactRow,
    kUIDisplayContactRow,
};


@interface ContactsTableViewController () <UITableViewDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, copy) NSArray* allContacts;
@property(nonatomic, assign) id< MFMessageComposeViewControllerDelegate > messageComposeDelegate;
@property(nonatomic, strong) NSMutableArray *recipients;
@property(nonatomic, strong) NSMutableArray *digits;

@property(nonatomic, copy) NSString *message;

@end


@implementation ContactsTableViewController

#pragma mark Load Views
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Create an address book object
    self.addressBook = ABAddressBookCreateWithOptions(NULL,NULL);

    self.recipients = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
    
    [self checkAddressBookAccess];
}

#pragma mark Address Book Access
// Check the authorization status of our application for Address Book
- (void)checkAddressBookAccess
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                                            message:@"Permission was not granted for Contacts."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
- (void)requestAddressBookAccess
{
    ContactsTableViewController * __weak weakSelf = self;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf accessGrantedForAddressBook];
                                                         
                                                     });
                                                 }
                                             });
}

// This method is called when the user has granted access to their address book data.
- (void)accessGrantedForAddressBook
{
    NSArray *allContacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(self.addressBook));
    NSInteger numContacts = [allContacts count];

    
    NSMutableArray *allContactNamesTemp = [[NSMutableArray alloc] initWithCapacity:numContacts];
    
    for (NSInteger i = 0; i < numContacts; i++) {
        
        ABRecordRef person = (__bridge ABRecordRef)allContacts[i];
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        
        
        if (lastName == nil && firstName != nil)
            fullName = firstName;
        else if (firstName == nil && lastName != nil)
            fullName = lastName;
        else if (firstName == nil && lastName == nil)
            continue; // Don't add this contact
        
        [allContactNamesTemp addObject:fullName];
    }
    // Alphabetically sort contacts retrieved
    self.allContactNames = [allContactNamesTemp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


#pragma mark Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.allContactNames[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedName = self.allContactNames[indexPath.row];

    NSArray *allContacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(self.addressBook));
    NSInteger numContacts = [allContacts count];
    for (NSInteger i = 0; i < numContacts; i++) {
        
        ABRecordRef person = (__bridge ABRecordRef)allContacts[i];
        
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];

        if ([lastName length] == 0 && [firstName length] != 0)
            fullName = firstName;
        else if ([firstName length] == 0 && [lastName length] != 0)
            fullName = lastName;
        else if ([lastName length] == 0 && [firstName length] == 0)
            continue;

        if ([selectedName isEqualToString:fullName]){
            ABRecordRef selectedPerson = person;
            [self.recipients addObject:CFBridgingRelease(selectedPerson)];
            CFRelease(selectedPerson);
            //CFRelease(person);
            break;
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedName = self.allContactNames[indexPath.row];
    NSInteger numSelectedPeople = [self.recipients count];
    NSLog(@"%ld", (long)numSelectedPeople);
    for (int i = 0; i < numSelectedPeople; i++) {
//        ABRecordRef person = (__bridge ABRecordRef)self.recipients[i];
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue((__bridge ABRecordRef)([self.recipients objectAtIndex:i]), kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue((__bridge ABRecordRef)([self.recipients objectAtIndex:i]), kABPersonLastNameProperty));
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        if ([lastName length] == 0 && [firstName length] != 0)
            fullName = firstName;
        else if ([firstName length] == 0 && [lastName length] != 0)
            fullName = lastName;
        else if ([lastName length] == 0 && [firstName length] == 0)
            continue;
        
        if ([selectedName isEqualToString:fullName]){
            ABRecordRef selectedPerson = CFBridgingRetain([self.recipients objectAtIndex:i]);
            [self.recipients removeObject:CFBridgingRelease(selectedPerson)];
            break;
        }
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allContactNames count];
}

#pragma mark - MessageUI

- (IBAction)sendInvites:(id)sender {
    
    
    [self showSMS];
}

- (void)showSMS {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    [self getNumbers];
    NSString *message = [NSString stringWithFormat:@"I'm inviting you to join FindMe!"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];

    messageController.messageComposeDelegate = self;
    [messageController setRecipients:self.digits];
    [messageController setBody:message];
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
    CFRelease((__bridge CFTypeRef)(messageController));

}

- (void)getNumbers{
    self.digits = [[NSMutableArray alloc] init];
    ABMultiValueRef phoneProperty;
    NSArray *phoneArray;
    NSString *theDigits;
    for(int i = 0; i <[self.recipients count]; i++){
        phoneProperty = ABRecordCopyValue((__bridge ABRecordRef)(self.recipients[i]), kABPersonPhoneProperty);
        phoneArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        theDigits = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:0]];
        NSLog(@"Digitz %@", theDigits);
        [self.digits addObject:theDigits];
        NSLog(@"Digitz Array: %@", self.digits[i]);
    }
    
}




@end
