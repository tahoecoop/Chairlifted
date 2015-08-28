//
//  DiscoverViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/27/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "DiscoverViewController.h"
#import "NetworkRequests.h"
#import "Post.h"
#import "PostTopic.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "CustomFeedTableViewCell.h"
#import "CustomFeedWithPhotoTableViewCell.h"
#import "NSDate+TimePassage.h"
#import "TopicsFeedViewController.h"
#import "PostDetailViewController.h"
#import "DiscoverResortsViewController.h"
#import "UIAlertController+ReportInappropriate.h"


@interface DiscoverViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) NSArray *states;
@property (nonatomic) NSArray *topics;
@property (nonatomic) NSMutableArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) int skipCount;

@end

@implementation DiscoverViewController



- (void)viewDidLoad
{

    [super viewDidLoad];
    self.states = @[@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Georgia", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Missouri", @"Montana", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Dakota", @"Tennessee", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

-(void)viewWillAppear:(BOOL)animated
{

    if (!self.topics)
    {
        UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
        spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
        [activityView addSubview:spinnerImageView];
        [self.view addSubview:activityView];
        [spinnerImageView rotateLayerInfinite];

        [NetworkRequests getTopicsWithCompletion:^(NSArray *array)
        {
            self.topics = array;
            [activityView removeFromSuperview];
            [self.tableView reloadData];
        }];
    }
}


#pragma mark - tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segControl.selectedSegmentIndex == 0)
    {
        return self.topics.count;
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        return self.states.count;
    }
    else
    {
        return self.posts.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segControl.selectedSegmentIndex == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTopics"];
        PostTopic *postTopic = self.topics[indexPath.row];
        cell.textLabel.text = postTopic.name;
        return cell;
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellStates"];
        cell.textLabel.text = self.states[indexPath.row];
        return cell;
    }
    else
    {
        Post *post = self.posts[indexPath.row];
        if (post.image)
        {
            CustomFeedWithPhotoTableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"CellPostImage"];
            imageCell.titleLabel.text = post.title;
            imageCell.authorLabel.text = post.author.displayName;
            imageCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
            imageCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            imageCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
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
            CustomFeedTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"CellPostText"];
            textCell.postLabel.text = post.title;
            textCell.authorLabel.text = post.author.displayName;
            textCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
            textCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            textCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
            return textCell;
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

    if (self.segControl.selectedSegmentIndex == 2)
    {
        if (indexPath.row == self.skipCount - 5)
        {
            [NetworkRequests getPostsFromSearch:[self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
             {
                 [self.posts addObjectsFromArray:array];
                 self.skipCount = self.skipCount + 30;
                 [self.tableView reloadData];
             }];
        }
    }
}


- (IBAction)onSegControlToggle:(UISegmentedControl *)sender
{
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma mark -  search bar methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];


    self.posts = nil;
    self.skipCount = 30;
    NSString *searchText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchText.length > 0)
    {
        [NetworkRequests getPostsFromSearch:searchText WithSkipCount:0 andCompletion:^(NSArray *array)
        {
            self.posts = [NSMutableArray arrayWithArray:array];
            [activityView removeFromSuperview];
            [self.tableView reloadData];
        }];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTopicFeed"])
    {
        PostTopic *postTopic = self.topics[self.tableView.indexPathForSelectedRow.row];
        TopicsFeedViewController *vc = segue.destinationViewController;
        vc.postTopic = postTopic.name;
    }
    else if ([segue.identifier isEqualToString:@"ToResorts"])
    {
        DiscoverResortsViewController *vc = segue.destinationViewController;
        vc.state = self.states[self.tableView.indexPathForSelectedRow.row];
    }
    else
    {
        Post *post = self.posts[self.tableView.indexPathForSelectedRow.row];
        PostDetailViewController *vc = segue.destinationViewController;
        vc.post = post;
    }
}

@end
