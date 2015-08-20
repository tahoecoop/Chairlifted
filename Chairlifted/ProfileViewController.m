//
//  ProfileViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"
#import "UIAlertController+UIImagePicker.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *editProfilePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUser];
}

- (void)setUpUser
{
    if (!self.selectedUser)
    {
        self.selectedUser = [User currentUser];
        self.userNameLabel.text = self.selectedUser.username;
        self.imageView.image = [UIImage imageWithData:self.selectedUser.profileImage.getData];
    }
    else
    {
        self.editProfilePhotoButton.hidden = YES;
    }
    self.cancelButton.hidden = YES;
}

- (IBAction)onPhotoEditButtonPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Edit profile photo"])
    {
        UIAlertController *alert = [UIAlertController prepareForImagePicker:self];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        self.selectedUser.profileImage = [PFFile fileWithData:UIImageJPEGRepresentation(self.imageView.image, 0.25)];
        [self.selectedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            self.cancelButton.hidden = YES;
            [self.editProfilePhotoButton setTitle:@"Edit profile photo" forState:UIControlStateNormal];
            //Add an activity indicator and a cool animated alert that it saved
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.cancelButton.hidden = NO;
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.editProfilePhotoButton setTitle:@"Save" forState:UIControlStateNormal];

}


- (IBAction)onCancelButtonPressed:(UIButton *)sender
{
    self.imageView.image = [UIImage imageWithData:self.selectedUser.profileImage.getData];
}

@end
