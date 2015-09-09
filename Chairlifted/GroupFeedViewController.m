//
//  GroupFeedViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "GroupFeedViewController.h"
#import "Post.h"
#import "User.h"
#import "CustomFeedTableViewCell.h"
#import "NSDate+TimePassage.h"
#import "NetworkRequests.h"
#import "CustomFeedWithPhotoTableViewCell.h"
#import "PostDetailViewController.h"
#import "CreatePostViewController.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "GroupMemberListViewController.h"
#import "UIAlertController+ReportInappropriate.h"

@interface GroupFeedViewController ()


@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) CustomFeedTableViewCell *prototypeCell;
@property (nonatomic) CustomFeedWithPhotoTableViewCell *photoPrototypeCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int skipCount;
@property (nonatomic) BOOL continueLoading;
@property (nonatomic) UIView *activityView;
@property (nonatomic) SortSelection sortSelection;

@end

@implementation GroupFeedViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.posts = [NSMutableArray new];
    self.continueLoading = YES;
    self.sortSelection = SortSelectionHottest;

    self.activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [self.activityView addSubview:spinnerImageView];
    [self.view addSubview:self.activityView];
    [spinnerImageView rotateLayerInfinite];

    if (!self.joinGroup)
    {
        [NetworkRequests getJoinGroupIfAlreadyJoinedWithGroup:self.group andCompletion:^(NSArray *array)
         {
             self.joinGroup = array.firstObject;
             [self setUpGroupInfo];
         }];
    }
    else
    {
        [self setUpGroupInfo];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [self retrievePosts];
}

- (void)retrievePosts
{
    self.skipCount = 30;

    [NetworkRequests getPostsWithSkipCount:0 fromGroup:self.group sortedBy:self.sortSelection andIsPrivate:[self.group.isPrivate boolValue] completion:^(NSArray *array)
     {
         self.posts = [NSMutableArray arrayWithArray:array];
         [self.activityView removeFromSuperview];
         [self.tableView reloadData];
     }];

}

-(void)setUpGroupInfo
{
    if ([self.joinGroup.status isEqualToString:@"joined"] || [self.joinGroup.status isEqualToString:@"admin"])
    {
        self.joinGroup.lastViewed = [NSDate date];
        [self.joinGroup saveInBackground];
    }
}


#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.group.isPrivate boolValue] && (![self.joinGroup.status isEqualToString:@"joined"] || ![self.joinGroup.status isEqualToString:@"admin"]))
    {
        return 1;
    }
    else
    {
        return 2;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return self.posts.count;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        GroupFeedHeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        headerCell.groupNameLabel.text = self.group.name;
        headerCell.groupPurposeLabel.text = self.group.purpose;
        headerCell.shareButton.hidden = YES;
        headerCell.delegate = self;

        if ([self.joinGroup.status isEqualToString:@"joined"] || [self.joinGroup.status isEqualToString:@"admin"])
        {
            headerCell.createNewPostButton.hidden = NO;
        }
        else
        {
            headerCell.createNewPostButton.hidden = YES;
        }

        PFFile *imageData = self.group.imageThumbnail;
        [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             headerCell.groupImageView.image = [UIImage imageWithData:data scale:1.0];
         }];

        headerCell.group = self.group;
        headerCell.joinGroup = self.joinGroup;

        if ([self.joinGroup.status isEqualToString:@"admin"])
        {
            [headerCell.requestToJoinButton setTitle:@"Admin" forState:UIControlStateNormal];
        }
        else if ([self.joinGroup.status isEqualToString:@"joined"])
        {
            [headerCell.requestToJoinButton setTitle:@"Leave group" forState:UIControlStateNormal];
        }
        else if ([self.joinGroup.status isEqualToString:@"pending"])
        {
            [headerCell.requestToJoinButton setTitle:@"Pending" forState:UIControlStateNormal];
        }
        else
        {
            [headerCell.requestToJoinButton setTitle:@"Join" forState:UIControlStateNormal];
        }
        return headerCell;
    }
    else
    {
        Post *post = self.posts[indexPath.row];
        if (post.image)
        {
            CustomFeedWithPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithImage"];
            cell.titleLabel.text = post.title;
            cell.authorLabel.text = post.author.displayName;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i", (int)post.commentCount];
            cell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            cell.likesLabel.text = [NSString stringWithFormat:@"%i", post.likeCount];

            [cell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
            [cell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
            [cell.cardView.layer setShadowRadius:2.0];
            [cell.cardView.layer setShadowOpacity:0.5];

            PFFile *imageData = post.imageThumbnail;
            [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 cell.postImageView.image = [UIImage imageWithData:data scale:1.0];
             }];
            return cell;
        }
        else
        {
            CustomFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell.postLabel.text = post.title;
            cell.authorLabel.text = post.author.displayName;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i", (int)post.commentCount];
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
        [NetworkRequests getPostsWithSkipCount:self.skipCount fromGroup:self.group sortedBy:self.sortSelection andIsPrivate:[self.group.isPrivate boolValue] completion:^(NSArray *array)
         {
             [self.posts addObjectsFromArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
         }];
    }
}


- (IBAction)shareButtonPressed:(UIButton *)button
{

}


- (IBAction)moreButtonPressed:(UIButton *)button
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    PFInstallation *installation = [PFInstallation currentInstallation];
    UIAlertAction *notificationsAction;

    if ([installation.channels containsObject:[NSString stringWithFormat:@"group%@", self.group.objectId]])
    {
        notificationsAction = [UIAlertAction actionWithTitle:@"Turn off notifications" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
       {
           [installation removeObject:[NSString stringWithFormat:@"group%@", self.group.objectId] forKey:@"channels"];
           [installation saveInBackground];

           [alert dismissViewControllerAnimated:YES completion:nil];
       }];
    }
    else
    {
        notificationsAction = [UIAlertAction actionWithTitle:@"Turn on notifications" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
       {
           [installation addUniqueObject:[NSString stringWithFormat:@"group%@", self.group.objectId] forKey:@"channels"];
           [installation saveInBackground];

           [alert dismissViewControllerAnimated:YES completion:nil];
       }];
    }
    UIAlertAction *sort = [UIAlertAction actionWithTitle:@"Sort posts" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sort feed by:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *hottest = [UIAlertAction actionWithTitle:@"Hottest" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              self.sortSelection = SortSelectionHottest;
              [self retrievePosts];
          }];
        UIAlertAction *newest = [UIAlertAction actionWithTitle:@"Most Recent" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              self.sortSelection = SortSelectionNewest;
              [self retrievePosts];
          }];
        UIAlertAction *mostLiked = [UIAlertAction actionWithTitle:@"Most ❤️s" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              self.sortSelection = SortSelectionMostLikes;
              [self retrievePosts];
          }];
        UIAlertAction *mostComments = [UIAlertAction actionWithTitle:@"Most 💬s" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
          {
              self.sortSelection = SortSelectionMostComments;
              [self retrievePosts];
          }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
          {
              [alert dismissViewControllerAnimated:YES completion:nil];
          }];

        [alert addAction:hottest];
        [alert addAction:newest];
        [alert addAction:mostLiked];
        [alert addAction:mostComments];
        [alert addAction:cancel];

        [self presentViewController:alert animated:YES completion:nil];
    }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:sort];

    if ([self.joinGroup.status isEqualToString:@"joined"] || [self.joinGroup.status isEqualToString:@"admin"])
    {
        [alert addAction:notificationsAction];
    }

    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}


-(void)didEditJoinGroup
{
    [NetworkRequests getJoinGroupIfAlreadyJoinedWithGroup:self.group andCompletion:^(NSArray *array)
    {
        self.joinGroup = array.firstObject;
        [self.tableView reloadData];
        [self setUpGroupInfo];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MakeGroupPost"])
    {
        CreatePostViewController *vc = (CreatePostViewController *)[segue.destinationViewController topViewController];
        vc.group = self.group;
    }
    else if ([segue.identifier isEqualToString:@"ToPostDetailTextOnly"] || [segue.identifier isEqualToString:@"ToPostDetailImage"])
    {
        PostDetailViewController *vc = segue.destinationViewController  ;
        vc.post = self.posts[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.identifier isEqualToString:@"toGroupMembers"])
    {
        GroupMemberListViewController *vc = segue.destinationViewController;
        vc.group = self.group;
        vc.joinGroup = self.joinGroup;
    }
}



@end
