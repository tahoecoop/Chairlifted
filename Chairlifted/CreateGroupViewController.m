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
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"

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
    if ([self.groupTitleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && [self.groupPurposeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 && [self.groupTitleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 51 && [self.groupPurposeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 101)
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
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];

    Group *group = [Group new];
    group.name = [self.groupTitleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    group.purpose = [self.groupPurposeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (self.groupImageView.image)
    {
        group.imageThumbnail =  [PFFile fileWithData: UIImageJPEGRepresentation(self.groupImageView.image, 0.25)];
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
             if (group.isPrivate)
             {
                 joinGroup.status = @"admin";
             }
             else
             {
                 joinGroup.status = @"joined";
             }
             joinGroup.user = [User currentUser];
             joinGroup.lastViewed = [NSDate date];
             [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  [activityView removeFromSuperview];
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
        self.titleCharactersLeftLabel.text = [NSString stringWithFormat:@"%i/50 characters", (int)textView.text.length];

        if (textView.text.length > 50)
        {
            self.titleCharactersLeftLabel.textColor = [UIColor redColor];
        }
        else
        {
            self.titleCharactersLeftLabel.textColor = [UIColor blackColor];
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

        self.purposeCharactersLeftLabel.text = [NSString stringWithFormat:@"%i/100 characters", (int)textView.text.length];

        if (textView.text.length > 100)
        {
            self.purposeCharactersLeftLabel.textColor = [UIColor redColor];
        }
        else
        {
            self.purposeCharactersLeftLabel.textColor = [UIColor blackColor];
        }
    }
    [self checkIfCanPost];
}

@end

