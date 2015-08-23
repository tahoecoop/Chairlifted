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




@interface PostDetailViewController () <UITableViewDataSource, UITableViewDelegate>

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
    [NetworkRequests getPostComments:self.post withSkipCount:self.skipCount andCompletion:^(NSArray *array)
     {
         self.comments = [NSMutableArray arrayWithArray:array];
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
            cell.postImageView.image = [UIImage imageWithData:self.post.image.getData];
            
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
        cell.commentAuthorLabel.text = comment.author.username;
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
        header.postTitleLabel.text = self.post.title;
        header.minutesAgoLabel.text = [NSDate determineTimePassed:self.post.createdAt];
        header.likesLabel.text = [NSString stringWithFormat:@"%i likes",self.post.likeCount];
        header.userNameLabel.text = self.post.author.username;

        if (self.post.group)
        {
            header.groupNameLabel.text = self.post.group.name;
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
        header.parentTableView = self.tableView;
        header.post = self.post;
        [header checkIfLiked];
        return header;
    }
}

- (IBAction)onCommentButtonPressed:(UIButton *)sender
{
    if (self.post.image)
    {
        [self performSegueWithIdentifier:@"photoSegue" sender:sender];
    }
    else
    {
        [self performSegueWithIdentifier:@"textSegue" sender:sender];
    }
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



@end
