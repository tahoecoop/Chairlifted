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
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (nonatomic) BOOL changedProfilePicture;
@property (weak, nonatomic) IBOutlet UITextField *resortTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISwitch *likeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *commentSwitch;


@end

@implementation EditProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUserInfo];

    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];

    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0 toItem:self.view
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];

}


-(void)setUpUserInfo
{
    self.usernameLabel.text = [User currentUser].displayName;

    if ([User currentUser].email)
    {
        self.emailTextField.text = [User currentUser].email;
    }

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
             self.resortTextField.text = self.selectedResort.name;
         }];
    }
    else
    {
        self.resortTextField.placeholder = @"Select favorite mountain";
    }

    if ([[User currentUser].isSnowboarder boolValue])
    {
        [self.segControl setSelectedSegmentIndex:1];
    }
    else
    {
        [self.segControl setSelectedSegmentIndex:0];
    }


    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    if ([currentInstallation.channels containsObject:[NSString stringWithFormat:@"likes%@", [User currentUser].objectId]])
    {
        [self.likeSwitch setOn:YES];
    }
    else
    {
        [self.likeSwitch setOn:NO];
    }

    if ([currentInstallation.channels containsObject:[NSString stringWithFormat:@"comments%@", [User currentUser].objectId]])
    {
        [self.commentSwitch setOn:YES];
    }
    else
    {
        [self.commentSwitch setOn:NO];
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
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    user.email = self.emailTextField.text;

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
        user.profileImage = [PFFile fileWithData:UIImageJPEGRepresentation(self.profileImageView.image, 0.25)];
    }

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [activityView removeFromSuperview];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.resortTextField)
    {
        textField.userInteractionEnabled = NO;
        [self performSegueWithIdentifier:@"ToStates" sender:self];
    }
}



- (IBAction)onLikeSwitchChanged:(UISwitch *)sender
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (sender.on)
    {
//        [installation setObject:[NSNumber numberWithBool:YES] forKey:@"likes"];
        [installation addUniqueObject:[NSString stringWithFormat:@"likes%@", [User currentUser].objectId] forKey:@"channels"];
    }
    else
    {
//        [installation setObject:[NSNumber numberWithBool:NO] forKey:@"likes"];
        [installation removeObject:[NSString stringWithFormat:@"likes%@", [User currentUser].objectId] forKey:@"channels"];
    }
    [installation saveInBackground];
}


- (IBAction)onCommentSwitchChanged:(UISwitch *)sender
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (!installation[@"user"])
    {
        installation[@"user"] = [User currentUser];
    }

    if (sender.on)
    {
//        [installation setObject:[NSNumber numberWithBool:YES] forKey:@"comments"];
        [installation addUniqueObject:[NSString stringWithFormat:@"comments%@", [User currentUser].objectId] forKey:@"channels"];
    }
    else
    {
//        [installation setObject:[NSNumber numberWithBool:NO] forKey:@"comments"];
        [installation removeObject:[NSString stringWithFormat:@"comments%@", [User currentUser].objectId] forKey:@"channels"];
    }
    [installation saveInBackground];
}


-(IBAction)unwindSegue:(UIStoryboardSegue *)segue
{
    self.resortTextField.text = self.selectedResort.name;
    self.resortTextField.userInteractionEnabled = YES;
    [self.delegate didUpdateResort];
}


#pragma mark - Logout Method


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"logout"])
    {
        [User logOut];

        FBSDKLoginManager *login = [[FBSDKLoginManager alloc]init];

        [login logOut];

        [FBSDKAccessToken setCurrentAccessToken:nil];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
