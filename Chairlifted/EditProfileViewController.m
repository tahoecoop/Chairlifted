//
//  EditProfileViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "EditProfileViewController.h"
#import "User.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];


}
- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    User *user = [User currentUser];
    
}

-(IBAction)unwindSegue:(UIStoryboardSegue *)segue
{

}

@end
