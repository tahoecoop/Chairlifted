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

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setUpUser
{
    User *user = [User currentUser];
    self.userNameLabel.text = user.username;
    self.imageView.image = [UIImage imageWithData:user.profileImage.getData];
}

- (IBAction)onPhotoEditButtonPressed:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController prepareForImagePicker:self];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
