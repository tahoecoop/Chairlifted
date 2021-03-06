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
#import "ProfileHeaderTableViewCell.h"
#import "CustomFeedTableViewCell.h"
#import "CustomFeedWithPhotoTableViewCell.h"
#import "Post.h"
#import "NSDate+TimePassage.h"
#import "NetworkRequests.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "EditProfileViewController.h"
#import "PostDetailViewController.h"
#import "UIAlertController+ReportInappropriate.h"
#import <MessageUI/MessageUI.h>
#import "UIAlertController+SignInPrompt.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, updatedResortDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moreButton;
@property (nonatomic) NSMutableArray *myPosts;
@property (nonatomic) int skipCount;
@property (nonatomic) NSDictionary *weatherDict;
@property (nonatomic) Resort *resort;
@property (nonatomic) BOOL shouldUpdateResort;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.skipCount = 30;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.shouldUpdateResort = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self setUpUser];
}

- (void)setUpUser
{
    if (!self.selectedUser || [self.selectedUser isEqual:[User currentUser]])
    {
        [self.moreButton setImage:[UIImage imageNamed:@"editProfile"]];

        if (![User currentUser])
        {
            self.title = @"Profile";
            self.moreButton.enabled = NO;
            UIAlertController *alert = [UIAlertController alertToSignInWithCompletion:^(BOOL signIn)
            {
                if (signIn)
                {
                    [self performSegueWithIdentifier:@"loginBeforeProfile" sender:self];
                }
                else
                {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            [self presentViewController:alert animated:YES completion:nil];
            self.shouldUpdateResort = NO;
        }
        else
        {
            self.selectedUser = [User currentUser];
            self.title = self.selectedUser.displayName;
        }
    }
    else
    {
        [self.moreButton setImage:[UIImage imageNamed:@"ellipses"]];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        self.title = self.selectedUser.displayName;
    }

    if (!self.selectedUser.favoriteResort)
    {
        self.shouldUpdateResort = NO;
    }


    if (self.selectedUser)
    {
        UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
        spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
        [activityView addSubview:spinnerImageView];
        [self.view addSubview:activityView];
        [spinnerImageView rotateLayerInfinite];
        
        [NetworkRequests getPostsWithSkipCount:0 andUser:self.selectedUser andShowsPrivate:[self.selectedUser isEqual:[User currentUser]] completion:^(NSArray *array)
         {
             self.myPosts = nil;
             self.myPosts = [NSMutableArray arrayWithArray:array];

             if (self.shouldUpdateResort)
             {
                 self.resort = self.selectedUser.favoriteResort;
                 [self.resort fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
                  {
                      if (error)
                      {
                          [activityView removeFromSuperview];
                      }
                      else
                      {
                          [NetworkRequests getWeatherFromLatitude:self.resort.latitude andLongitude:self.resort.longitude andCompletion:^(NSDictionary *dictionary)
                           {
                               self.weatherDict = dictionary;
                               dispatch_async(dispatch_get_main_queue(),
                              ^{
                                   [activityView removeFromSuperview];
                               });
                               self.shouldUpdateResort = NO;
                               [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                           }];
                      }
                  }];
             }
             else
             {
                 [activityView removeFromSuperview];
             }
         }];
    }

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.myPosts.count;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        ProfileHeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell"];

        headerCell.nameLabel.text = self.selectedUser.name;
        if (self.resort && self.weatherDict)
        {
            headerCell.weatherLabel.text = [NSString stringWithFormat:@"%.f°", [self.weatherDict[@"temperature"] floatValue]];
            headerCell.weatherIconImageView.image = [UIImage imageNamed:self.weatherDict[@"icon"]];

            if (self.resort)
            {
                headerCell.locationLabel.text = self.resort.name;
            }
            else
            {
                headerCell.locationLabel.text = @"No favorite mountain chosen";
            }
        }

        PFFile *imageData = self.selectedUser.profileImage;
        [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             headerCell.profileImageView.image = [UIImage imageWithData:data scale:0.7];
         }];

        return headerCell;
    }
    else
    {
        Post *post = self.myPosts[indexPath.row];
        if (post.image)
        {
            CustomFeedWithPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImagePostCell"];
            cell.authorLabel.text = post.author.displayName;
            cell.titleLabel.text = post.title;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i", post.commentCount];
            cell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            cell.likesLabel.text = [NSString stringWithFormat:@"%i", post.likeCount];

            [cell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
            [cell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
            [cell.cardView.layer setShadowRadius:2.0];
            [cell.cardView.layer setShadowOpacity:0.5];


            PFFile *imageData = post.image;
            [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 cell.postImageView.image = [UIImage imageWithData:data scale:1.0];
             }];

            return cell;
        }
        else
        {
            CustomFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextPostCell"];
            cell.authorLabel.text = post.author.displayName;
            cell.postLabel.text = post.title;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i", post.commentCount];
            cell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            cell.likesLabel.text = [NSString stringWithFormat:@"%i", post.likeCount];

            [cell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
            [cell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
            [cell.cardView.layer setShadowRadius:2.0];
            [cell.cardView.layer setShadowOpacity:0.5];


            return cell;
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    if (indexPath.row == self.skipCount - 5)
    {
        [NetworkRequests getPostsWithSkipCount:self.skipCount andUser:self.selectedUser andShowsPrivate:[self.selectedUser isEqual:[User currentUser]] completion:^(NSArray *array)
         {
             [self.myPosts addObjectsFromArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
         }];
    }
}

-(void)didUpdateResort
{
    self.shouldUpdateResort = YES;
}


- (IBAction)moreButtonPressed:(UIBarButtonItem *)button
{
    if (self.selectedUser == [User currentUser])
    {
        [self performSegueWithIdentifier:@"EditProfile" sender:self];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertForReportInappropriateWithCompletion:^(BOOL sendReport)
        {
            if (sendReport)
            {
                if ([MFMailComposeViewController canSendMail])
                {
                    MFMailComposeViewController *mailer = [MFMailComposeViewController new];
                    mailer.mailComposeDelegate = self;

                    [mailer setSubject:@"Report User"];

                    NSArray *toRecipients = @[@"chairlifted.devteam@gmail.com"];
                    [mailer setToRecipients:toRecipients];

                    NSString *emailBody = [NSString stringWithFormat:@"User: %@ \n\n\nThank you for your feedback. Please explain why you are reporting this user as inappropriate: \n\t", self.selectedUser.displayName];
                    [mailer setMessageBody:emailBody isHTML:NO];

                    [self presentViewController:mailer animated:YES completion:nil];
                }
                else
                {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Your device is not set up to send emails" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                           {
                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                           }];
                    
                    [alert addAction:okay];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditProfile"])
    {
        EditProfileViewController *vc = (EditProfileViewController *)[segue.destinationViewController topViewController];
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"FromProfileToDetailText"] || [segue.identifier isEqualToString:@"FromProfileToDetailImage"])
    {
        PostDetailViewController *vc = segue.destinationViewController;
        vc.post = self.myPosts[self.tableView.indexPathForSelectedRow.row];
    }
}


#pragma mark - MFMailCompose Methods

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;

        case MFMailComposeResultFailed:
            break;

        case MFMailComposeResultSaved:
            break;

        case MFMailComposeResultSent:
            break;

        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}






@end
