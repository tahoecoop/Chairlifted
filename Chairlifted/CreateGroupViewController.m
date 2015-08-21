//
//  CreateGroupViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "UIAlertController+UIImagePicker.h"
#import "Group.h"
#import "JoinGroup.h"
#import "User.h"

@interface CreateGroupViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *groupTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *groupPurposeTextView;
@property (weak, nonatomic) IBOutlet UIButton *uploadImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleCharactersLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *purposeCharactersLeftLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *groupTitlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupPurposePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;


@end

@implementation CreateGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (IBAction)onUploadImageButtonPressed:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController prepareForImagePicker:self];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.groupImageView.image = info[UIImagePickerControllerOriginalImage];
    [self checkIfCanPost];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkIfCanPost
{
    if ([self.groupTitleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && [self.groupPurposeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        self.saveButton.enabled = YES;
    }
    else
    {
        self.saveButton.enabled = NO;
    }
}


- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    Group *group = [Group new];
    group.name = [self.groupTitleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    group.purpose = [self.groupPurposeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (self.groupImageView.image)
    {
        group.image =  [PFFile fileWithData: UIImageJPEGRepresentation(self.groupImageView.image, 1.0)];
    }

    group.memberQuantity = 1;
    group.mostRecentPost = nil;

    if (self.segControl.selectedSegmentIndex == 0)
    {
        group.isPrivate = [NSNumber numberWithBool:NO];
    }
    else
    {
        group.isPrivate = [NSNumber numberWithBool:YES];
    }

    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             JoinGroup *joinGroup = [JoinGroup new];
             joinGroup.group = group;
             joinGroup.groupName = group.name;
             joinGroup.status = @"joined";
             joinGroup.user = [User currentUser];
             joinGroup.lastViewed = [NSDate date];
             [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  [self.delegate didFinishSaving];
                  [self dismissViewControllerAnimated:YES completion:nil];
              }];
         }
     }];
}

#pragma mark - TextView Methods


-(void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.groupTitleTextView)
    {
        if (textView.text.length > 0)
        {
            self.groupTitlePlaceholderLabel.hidden = YES;
        }
        else
        {
            self.groupTitlePlaceholderLabel.hidden = NO;
        }
    }
    else if (textView == self.groupPurposeTextView)
    {
        if (textView.text.length > 0)
        {
            self.groupPurposePlaceholderLabel.hidden = YES;

        }
        else
        {
            self.groupPurposePlaceholderLabel.hidden = NO;
        }
    }
    [self checkIfCanPost];
}

@end

