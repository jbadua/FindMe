//
//  MainMenuViewController.m
//  FindMe
//
//  Created by Daniel Legler on 5/14/15.
//  Copyright (c) 2015 CS 117. All rights reserved.
//

#import "MainMenuViewController.h"

@implementation MainMenuViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

@end
