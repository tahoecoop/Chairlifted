//
//  EditProfileViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "EditProfileViewController.h"
#import "User.h"
#import "UIAlertController+UIImagePicker.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface EditProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *editPictureLabel;
@property (strong, nonatomic) IBOutlet UIButton *changeFavoriteResortButton;

@end

@implementation EditProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInfo];
}


-(void)setUpUserInfo
{
    self.usernameLabel.text = [User currentUser].username;

    if ([User currentUser].name)
    {
        self.fullNameTextField.text = [User currentUser].name;
    }

    if ([User currentUser].profileImage)
    {
        self.profileImageView.image = [UIImage imageWithData:[User currentUser].profileImage.getData scale:0.3];
        self.editPictureLabel.text = @"Edit";
    }
    else
    {
        self.editPictureLabel.text = @"Add Photo";
        self.profileImageView.layer.borderColor = [UIColor greenColor].CGColor;
        self.profileImageView.layer.borderWidth = 1.0;
    }

    if ([User currentUser].favoriteResort)
    {
        self.selectedResort = [User currentUser].favoriteResort;
        [self.selectedResort fetchIfNeeded];
        self.resortNameLabel.text = self.selectedResort.name;
    }
    else
    {
        self.resortNameLabel.text = @"";
        [self.changeFavoriteResortButton setTitle:@"Add Favorite Resort" forState:UIControlStateNormal];
    }
}


- (IBAction)onEditProfilePictureButtonPressed:(UIButton *)button
{
    UIAlertController *editPhotoAlert = [UIAlertController prepareForImagePicker:self];
    [self presentViewController:editPhotoAlert animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.profileImageView.image = info[UIImagePickerControllerOriginalImage];
    [self checkIfEditsMade];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    User *user = [User currentUser];
    user.name = [self.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.favoriteResort = self.selectedResort;
    if (self.profileImageView.image)
    {
        user.profileImage = [PFFile fileWithData:UIImageJPEGRepresentation(self.profileImageView.image, 1.0)];
    }

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)checkIfEditsMade
{
    if ([[self.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:[User currentUser].name])
    {
        self.fullNameTextField.textColor = [UIColor blackColor];
    }
    else
    {
        self.fullNameTextField.textColor = [UIColor redColor];
    }

    if ([self.resortNameLabel.text isEqualToString:[User currentUser].favoriteResort.name])
    {
        self.resortNameLabel.textColor = [UIColor blackColor];
    }
    else
    {
        self.resortNameLabel.textColor = [UIColor redColor];
    }

    if ([User currentUser].profileImage == [PFFile fileWithData:UIImageJPEGRepresentation(self.profileImageView.image, 1.0)])
    {
        self.profileImageView.layer.borderColor = [UIColor redColor].CGColor;
        self.profileImageView.layer.borderWidth = 1.0;
    }
    else
    {
        self.profileImageView.layer.borderColor = [UIColor blackColor].CGColor;
        self.profileImageView.layer.borderWidth = 0.0;
    }
}


- (IBAction)editingDidChange:(UITextField *)textField
{
    [self checkIfEditsMade];
}


-(IBAction)unwindSegue:(UIStoryboardSegue *)segue
{
    [self checkIfEditsMade];
    self.resortNameLabel.text = self.selectedResort.name;
    [self.changeFavoriteResortButton setTitle:@"Change Favorite Resort" forState:UIControlStateNormal];
}


#pragma mark - Logout Method


- (IBAction)onLogoutButtonPressed:(UIButton *)sender {
    
    [PFUser logOut];

    [FBSDKAccessToken setCurrentAccessToken:nil];

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc]init];

    [login logOut];
    
    [self performSegueWithIdentifier:@"logout" sender:self];
}


@end
