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

@interface TopicsFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) int skipCount;

@end

@implementation TopicsFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getTopics];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];


}

- (void)getTopics
{
     [NetworkRequests getPostsWithTopic:self.postTopic WithSkipCount:self.skipCount andCompletion:^(NSArray *array)
    {
        self.posts = [NSMutableArray arrayWithArray:array];
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
        return textCell;
    }
}

@end
