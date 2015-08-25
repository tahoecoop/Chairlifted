//
//  SearchViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/22/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "SearchViewController.h"
#import "NetworkRequests.h"
#import "NSDate+TimePassage.h"
#import "GroupFeedViewController.h"
#import "PostDetailViewController.h"


@interface SearchViewController ()

@property (nonatomic) NSMutableArray *results;
@property (nonatomic) int skipCount;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.skipCount = 0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.hidden = YES;
}

- (void)populateTheCells:(NSString *)searchText
{
    self.results = nil;
    if (self.isGroup)
    {
        [NetworkRequests getGroupsFromSearch:searchText WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
         {
             self.results = [NSMutableArray arrayWithArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
             self.tableView.hidden = NO;
         }];
    }
    else
    {
        [NetworkRequests getPostsFromSearch:searchText WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
        {
            self.results = [NSMutableArray arrayWithArray:array];
            self.skipCount = self.skipCount + 30;
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - table view

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isGroup)
    {
        GroupCustomTableViewCell *groupCell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
        Group *group = self.results[indexPath.row];
        groupCell.groupNameLabel.text = group.name;
        groupCell.memberQuantityLabel.text = [NSString stringWithFormat:@"%i members", group.memberQuantity];
        groupCell.lastUpdatedLabel.text = [NSDate determineTimePassed:group.mostRecentPost];

        if (group.isPrivate)
        {
            groupCell.privateImageView.hidden = NO;
        }
        else
        {
            groupCell.privateImageView.hidden = YES;
        }
        groupCell.backgroundColor = [UIColor whiteColor];
        tableView.backgroundColor = [UIColor clearColor];

        return groupCell;
    }
    else
    {
        Post *post = self.results[indexPath.row];
        if (post.image)
        {
            CustomFeedWithPhotoTableViewCell *postPhotoCell = [tableView dequeueReusableCellWithIdentifier:@"PostPhotoCell"];
            postPhotoCell.titleLabel.text = post.title;
            postPhotoCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
            postPhotoCell.authorLabel.text = post.author.username;
            postPhotoCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", post.commentCount];
            postPhotoCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            postPhotoCell.postImageView.image = [UIImage imageWithData:post.image.getData scale:0.3];
            postPhotoCell.backgroundColor = [UIColor whiteColor];
            tableView.backgroundColor = [UIColor clearColor];

            return postPhotoCell;
        }
        else
        {
            CustomFeedTableViewCell *postTextCell = [tableView dequeueReusableCellWithIdentifier:@"PostTextCell"];
            postTextCell.postLabel.text = post.title;
            postTextCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
            postTextCell.authorLabel.text = post.author.username;
            postTextCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", post.commentCount];
            postTextCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
            postTextCell.backgroundColor = [UIColor whiteColor];
            tableView.backgroundColor = [UIColor clearColor];

            return postTextCell;
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
        if (self.isGroup)
        {
            [NetworkRequests getGroupsFromSearch:[self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
             {
                 [self.results addObjectsFromArray:array];
                 self.skipCount = self.skipCount + 30;
                 [self.tableView reloadData];
             }];
        }
        else
        {
            [NetworkRequests getPostsFromSearch:[self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
             {
                 [self.results addObjectsFromArray:array];
                 self.skipCount = self.skipCount + 30;
                 [self.tableView reloadData];
             }];
        }
    }
}

#pragma mark - search methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.skipCount = 0;
    [self populateTheCells:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.searchBar.text isEqualToString:@""])
    {
        self.tableView.hidden = YES;
        [searchBar resignFirstResponder];
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchToGroupFeed"])
    {
        GroupFeedViewController *vc = segue.destinationViewController;
        vc.group = self.results[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.identifier isEqualToString:@"SearchPostImageToDetail"] || [segue.identifier isEqualToString:@"SearchPostTextToDetail"])
    {
        PostDetailViewController *vc = segue.destinationViewController;
        vc.post = self.results[self.tableView.indexPathForSelectedRow.row];
    }
}


@end
