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

@interface GroupFeedViewController ()


@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) CustomFeedTableViewCell *prototypeCell;
@property (nonatomic) CustomFeedWithPhotoTableViewCell *photoPrototypeCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int skipCount;
@property (nonatomic) BOOL continueLoading;


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
}


-(void)viewWillAppear:(BOOL)animated
{
    self.skipCount = 30;

    [NetworkRequests getPostsWithSkipCount:0 andGroup:self.group completion:^(NSArray *array)
     {
         self.posts = [NSMutableArray arrayWithArray:array];
         [self.tableView reloadData];
     }];

}


#pragma mark - TableView Delegate

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
    if (indexPath.row == self.skipCount - 5)
    {
        [NetworkRequests getPostsWithSkipCount:self.skipCount andGroup:self.group completion:^(NSArray *array)
         {
             [self.posts addObjectsFromArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
         }];
    }
}


@end