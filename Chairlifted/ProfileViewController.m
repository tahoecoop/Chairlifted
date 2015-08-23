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


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) NSMutableArray *myPosts;
@property (nonatomic) int skipCount;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUser];
    self.skipCount = 0;
    self.title = self.selectedUser.username;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{

    [NetworkRequests getPostsWithSkipCount:self.skipCount andUser:self.selectedUser andShowsPrivate:[self.selectedUser isEqual:[User currentUser]] completion:^(NSArray *array)
    {
        self.myPosts = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
    }];
}

- (void)setUpUser
{
    if (!self.selectedUser || [self.selectedUser isEqual:[User currentUser]])
    {
        self.selectedUser = [User currentUser];
    }
    else
    {
        self.editButton.enabled = NO;
        self.editButton.tintColor = [UIColor clearColor];
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
        Resort *resort = self.selectedUser.favoriteResort;
        [resort fetchIfNeeded];
        headerCell.locationLabel.text = resort.name;
        headerCell.profileImageView.image = [UIImage imageWithData:self.selectedUser.profileImage.getData scale:0.3];

        return headerCell;
    }
    else
    {
        Post *post = self.myPosts[indexPath.row];
        if (post.image)
        {
            CustomFeedWithPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImagePostCell"];
            cell.authorLabel.text = post.author.username;
            cell.titleLabel.text = post.title;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", post.commentCount];
            cell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            cell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
            cell.postImageView.image = [UIImage imageWithData:post.image.getData scale:0.3];
            return cell;
        }
        else
        {
            CustomFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextPostCell"];
            cell.authorLabel.text = post.author.username;
            cell.postLabel.text = post.title;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", post.commentCount];
            cell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            cell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];

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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}








@end
