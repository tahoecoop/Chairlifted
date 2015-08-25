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
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"

@interface EditProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *editPictureLabel;
@property (strong, nonatomic) IBOutlet UIButton *changeFavoriteResortButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (nonatomic) BOOL changedProfilePicture;

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
        PFFile *imageData = [User currentUser].profileImage;
        [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             self.profileImageView.image = [UIImage imageWithData:data scale:0.4];
         }];

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
        [self.selectedResort fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             self.resortNameLabel.text = self.selectedResort.name;
         }];
    }
    else
    {
        self.resortNameLabel.text = @"";
        [self.changeFavoriteResortButton setTitle:@"Add Favorite Resort" forState:UIControlStateNormal];
    }

    if ([[User currentUser].isSnowboarder boolValue])
    {
        [self.segControl setSelectedSegmentIndex:1];
    }
    else
    {
        [self.segControl setSelectedSegmentIndex:0];
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
    self.changedProfilePicture = YES;
    [self checkIfEditsMade];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];

    User *user = [User currentUser];
    user.name = [self.fullNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    user.favoriteResort = self.selectedResort;

    if (self.segControl.selectedSegmentIndex == 0)
    {
        user.isSnowboarder = [NSNumber numberWithBool:NO];
    }
    else
    {
        user.isSnowboarder = [NSNumber numberWithBool:YES];
    }

    if (self.changedProfilePicture)
    {
        user.profileImage = [PFFile fileWithData:UIImageJPEGRepresentation(self.profileImageView.image, 1.0)];
    }

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [activityView removeFromSuperview];
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

    if (self.changedProfilePicture)
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


-(IBAction)unwindSegue:(UIStoryboardSegue *)segue
{
    [self checkIfEditsMade];
    self.resortNameLabel.text = self.selectedResort.name;
    [self.changeFavoriteResortButton setTitle:@"Change Favorite Resort" forState:UIControlStateNormal];
}


#pragma mark - Logout Method


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"logout"])
    {
        [User logOut];

        [FBSDKAccessToken setCurrentAccessToken:nil];

        FBSDKLoginManager *login = [[FBSDKLoginManager alloc]init];

        [login logOut];
    }
}


@end
