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
#import "GroupFeedHeaderTableViewCell.h"
#import "CreatePostViewController.h"

@interface GroupFeedViewController ()


@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) CustomFeedTableViewCell *prototypeCell;
@property (nonatomic) CustomFeedWithPhotoTableViewCell *photoPrototypeCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int skipCount;
@property (nonatomic) BOOL continueLoading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *makeNewPostButton;


@end

@implementation GroupFeedViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.posts = [NSMutableArray new];
    self.continueLoading = YES;
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
    self.skipCount = 30;

    [NetworkRequests getPostsWithSkipCount:0 andGroup:self.group andIsPrivate:self.group.isPrivate completion:^(NSArray *array)
     {
         self.posts = [NSMutableArray arrayWithArray:array];
         [self.tableView reloadData];
     }];
}


-(void)setUpGroupInfo
{
    if ([self.joinGroup.status isEqualToString:@"joined"])
    {
        self.makeNewPostButton.enabled = YES;
    }
    else
    {
        self.makeNewPostButton.enabled = NO;
        self.makeNewPostButton.tintColor = [UIColor clearColor];
    }
}


#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.group.isPrivate && ![self.joinGroup.status isEqualToString:@"joined"])
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
        headerCell.groupNameLabel.text = self.group.name;
        headerCell.groupPurposeLabel.text = self.group.purpose;
        headerCell.groupImageView.image = [UIImage imageWithData:self.group.image.getData scale:0.5];

        if ([self.joinGroup.status isEqualToString:@"joined"])
        {
            [headerCell.requestToJoinButton setTitle:@"Leave group" forState:UIControlStateNormal];
        }
//        else if ([self.joinGroup.status isEqualToString:@""])
//        {
//
//        }
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
            cell.authorLabel.text = post.author.username;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
            cell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            cell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
            cell.postImageView.image = [UIImage imageWithData:post.image.getData scale:0.2];
            return cell;
        }
        else
        {
            CustomFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell.postLabel.text = post.title;
            cell.authorLabel.text = post.author.username;
            cell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
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
        [NetworkRequests getPostsWithSkipCount:self.skipCount andGroup:self.group andIsPrivate:self.group.isPrivate completion:^(NSArray *array)
         {
             [self.posts addObjectsFromArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
         }];
    }
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
}



@end
