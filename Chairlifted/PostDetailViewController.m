//
//  PostDetailViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "PostDetailViewController.h"
#import "DetailHeaderTableViewCell.h"
#import "DetailPostImageTableViewCell.h"
#import "DetailPostTextOnlyTableViewCell.h"
#import "DetailActionTableViewCell.h"
#import "DetailCommentTableViewCell.h"
#import "Comment.h"
#import "NSDate+TimePassage.h"
#import "CreateCommentWithImageViewController.h"
#import "CreateCommentWithTextViewController.h"
#import "NetworkRequests.h"
#import "Like.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "UIAlertController+ReportInappropriate.h"
#import <MessageUI/MessageUI.h>




@interface PostDetailViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *comments;
@property (nonatomic)int skipCount;

@end

@implementation PostDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.estimatedSectionHeaderHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.skipCount = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];


    [NetworkRequests getPostComments:self.post withSkipCount:self.skipCount andCompletion:^(NSArray *array)
     {
         self.comments = [NSMutableArray arrayWithArray:array];
         [activityView removeFromSuperview];
         [self.tableView reloadData];
     }];

}
//-(void)viewDidAppear:(BOOL)animated
//{
//    [self.tableView reloadData];
//}

#pragma mark - Table View Methods

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
        return self.comments.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.post.image)
        {
            DetailPostImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImagePost"];
            cell.postText.text = self.post.text;
            PFFile *imageData = self.post.image;
            [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 cell.postImageView.image = [UIImage imageWithData:data scale:1.0];
             }];
            
            return cell;
        }
        else
        {
            DetailPostTextOnlyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextPost"];
            cell.postText.text = self.post.text;
            return cell;
        }

    }
    else
    {
        DetailCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        Comment *comment = self.comments[indexPath.row];
        cell.commentAuthorLabel.text = comment.author.displayName;
        cell.commentTextLabel.text = comment.text;
        cell.commentTimeLabel.text = [NSDate determineTimePassed:comment.createdAt];

        return cell;
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
        [NetworkRequests getPostComments:self.post withSkipCount:self.skipCount andCompletion:^(NSArray *array)
         {
             [self.comments addObjectsFromArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
         }];
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        DetailHeaderTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        header.selectionStyle = UITableViewCellSelectionStyleNone;
        header.postTitleLabel.text = self.post.title;
        header.minutesAgoLabel.text = [NSDate determineTimePassed:self.post.createdAt];
        header.likesLabel.text = [NSString stringWithFormat:@"%i likes",self.post.likeCount];
        header.userNameLabel.text = self.post.author.displayName;

        if (self.post.group)
        {
            Group *postGroup = self.post.group;
            [postGroup fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
            {
                if (!error)
                {
                    header.groupNameLabel.text = postGroup.name;
                }
            }];
        }
        else
        {
            header.groupNameLabel.hidden = YES;
        }
        return header;
    }
    else
    {
        DetailActionTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:@"Action"];
        header.selectionStyle = UITableViewCellSelectionStyleNone;
        header.parentTableView = self.tableView;
        header.post = self.post;

        [header checkIfLiked];
        return header;
    }
}


- (IBAction)onLikeButtonPressed:(UIButton *)button
{
    if (![User currentUser])
    {
        [self performSegueWithIdentifier:@"loginBeforeLikePost" sender:button];
    }
}

- (IBAction)onCommentButtonPressed:(UIButton *)button
{
    if ([User currentUser])
    {
        if (self.post.image)
        {
            [self performSegueWithIdentifier:@"photoSegue" sender:button];
        }
        else
        {
            [self performSegueWithIdentifier:@"textSegue" sender:button];
        }
    }
    else
    {
        [self performSegueWithIdentifier:@"loginBeforeLikePost" sender:button];
    }
}


- (IBAction)onMoreButtonPressed:(UIBarButtonItem *)button
{
    UIAlertController *alert = [UIAlertController alertForReportInappropriateWithCompletion:^(BOOL sendReport)
    {
        if (sendReport)
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailer = [MFMailComposeViewController new];
                mailer.delegate = self;

                [mailer setSubject:@"Report User"];

                NSArray *toRecipients = @[@"chairlifted.devteam@gmail.com"];
                [mailer setToRecipients:toRecipients];

                NSString *emailBody = [NSString stringWithFormat:@"PostID: %@ \n\n\nThank you for your feedback. Please explain why you are reporting this post as inappropriate: \n\t", self.post.objectId];
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"photoSegue"])
    {
        CreateCommentWithImageViewController *vc = (CreateCommentWithImageViewController *)[segue.destinationViewController topViewController];
        vc.post = self.post;

    }
    else if ([segue.identifier isEqualToString:@"textSegue"])
    {
        CreateCommentWithTextViewController *vc = (CreateCommentWithTextViewController *)[segue.destinationViewController topViewController];
        vc.post = self.post;
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
