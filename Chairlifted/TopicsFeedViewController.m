//
//  TopicsFeedViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/27/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "TopicsFeedViewController.h"
#import "CustomFeedWithPhotoTableViewCell.h"
#import "CustomFeedTableViewCell.h"
#import "Post.h"
#import "NSDate+TimePassage.h"
#import "NetworkRequests.h"
#import "PostDetailViewController.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "UIAlertController+ReportInappropriate.h"

@interface TopicsFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) int skipCount;

@end

@implementation TopicsFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.skipCount = 30;

    if (self.postTopic)
    {
        [self getTopicPosts];
    }
    else
    {
        [self getResortPosts];
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)getTopicPosts
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];

     [NetworkRequests getPostsWithTopic:self.postTopic WithSkipCount:0 andCompletion:^(NSArray *array)
    {
        if (self.posts)
        {
            [self.posts addObjectsFromArray:array];
        }
        else
        {
            self.posts = [NSMutableArray arrayWithArray:array];
        }
        [activityView removeFromSuperview];
        [self.tableView reloadData];
    }];
}


-(void)getResortPosts
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];

    [NetworkRequests getPostsWithSkipCount:0 andResort:self.resort andCompletion:^(NSArray *array)
    {
        if (self.posts)
        {
            [self.posts addObjectsFromArray:array];
        }
        else
        {
            self.posts = [NSMutableArray arrayWithArray:array];
        }
        [activityView removeFromSuperview];
        [self.tableView reloadData];
    }];
}


#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = self.posts[indexPath.row];
    if (post.image)
    {
        CustomFeedWithPhotoTableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"CellImage"];
        imageCell.titleLabel.text = post.title;
        imageCell.authorLabel.text = post.author.displayName;
        imageCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
        imageCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
        imageCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];

        [imageCell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
        [imageCell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
        [imageCell.cardView.layer setShadowRadius:2.0];
        [imageCell.cardView.layer setShadowOpacity:0.5];

        PFFile *postImage = post.imageThumbnail;
        [postImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 imageCell.postImageView.image = [UIImage imageWithData:data scale:1.0];
             }
         }];
        return imageCell;
    }
    else
    {
        CustomFeedTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"CellText"];
        textCell.postLabel.text = post.title;
        textCell.authorLabel.text = post.author.displayName;
        textCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
        textCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
        textCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];

        [textCell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
        [textCell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
        [textCell.cardView.layer setShadowRadius:2.0];
        [textCell.cardView.layer setShadowOpacity:0.5];

        return textCell;
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
        if (self.postTopic)
        {
            [NetworkRequests getPostsWithTopic:self.postTopic WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
            {
                [self.posts addObjectsFromArray:array];
                self.skipCount = self.skipCount + 30;
                [tableView reloadData];
            }];
        }
        else
        {
            [NetworkRequests getPostsWithSkipCount:self.skipCount andResort:self.resort andCompletion:^(NSArray *array)
            {
                [self.posts addObjectsFromArray:array];
                self.skipCount = self.skipCount + 30;
                [tableView reloadData];
            }];
        }
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PostDetailViewController *vc = segue.destinationViewController;
    vc.post = self.posts[self.tableView.indexPathForSelectedRow.row];
}

@end
