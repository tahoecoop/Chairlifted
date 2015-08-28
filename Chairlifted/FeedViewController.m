//
//  ViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "FeedViewController.h"
#import "Post.h"
#import "User.h"
#import "CustomFeedTableViewCell.h"
#import "NSDate+TimePassage.h"
#import "NetworkRequests.h"
#import "CustomFeedWithPhotoTableViewCell.h"
#import "PostDetailViewController.h"
#import "LoginViewController.h"
#import "UIImage+SkiSnowboardIcon.h"

@interface FeedViewController ()

@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) CustomFeedTableViewCell *prototypeCell;
@property (nonatomic) CustomFeedWithPhotoTableViewCell *photoPrototypeCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int skipCount;
@property (nonatomic) BOOL continueLoading;


@end

@implementation FeedViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.posts = [NSMutableArray new];
    self.continueLoading = YES;
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];

}

-(void)viewDidAppear:(BOOL)animated
{
//    if (![User currentUser])
//    {
//        PFLogInViewController *loginVC = [PFLogInViewController new];
//        loginVC.delegate = self;
//        PFSignUpViewController *signupVC = [PFSignUpViewController new];
//        signupVC.delegate = self;
//        [loginVC setSignUpController:signupVC];
//        [self presentViewController:loginVC animated:YES completion:nil];


//        [self performSegueWithIdentifier:@"loginFirst" sender:self];
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
//    if ([User currentUser])
//    {
        self.skipCount = 30;

        [NetworkRequests getPostsWithSkipCount:0 andGroup:nil andIsPrivate:NO completion:^(NSArray *array)
         {
             self.posts = [NSMutableArray arrayWithArray:array];
             [self.tableView reloadData];
         }];
//    }
}


#pragma mark - Parse Delegate Methods

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             [signUpController dismissViewControllerAnimated:YES completion:nil];
         }
     }];
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [logInController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.posts.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = self.posts[indexPath.row];
    if (post.image)
    {
        CustomFeedWithPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithImage"];
        [self configureCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    else
    {
        CustomFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        [self configureCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
}


- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CustomFeedTableViewCell class]])
    {
        CustomFeedTableViewCell *textCell = (CustomFeedTableViewCell *)cell;
        Post *post = self.posts[indexPath.row];
        textCell.postLabel.text = post.title;
        textCell.authorLabel.text = post.author.displayName;
        textCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
        textCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
        textCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
    }
    else if ([cell isKindOfClass:[CustomFeedWithPhotoTableViewCell class]])
    {
        CustomFeedWithPhotoTableViewCell *textCell = (CustomFeedWithPhotoTableViewCell *)cell;
        Post *post = self.posts[indexPath.row];
        textCell.titleLabel.text = post.title;
        textCell.authorLabel.text = post.author.displayName;
        textCell.repliesLabel.text = [NSString stringWithFormat:@"%i comments", (int)post.commentCount];
        textCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
        textCell.likesLabel.text = [NSString stringWithFormat:@"%i likes", post.likeCount];
        PFFile *postImage = post.imageThumbnail;
        [postImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
        {
            if (!error)
            {
                textCell.postImageView.image = [UIImage imageWithData:data scale:1.0];
            }
        }];

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
        [NetworkRequests getPostsWithSkipCount:self.skipCount andGroup:nil andIsPrivate:NO completion:^(NSArray *array)
        {
             [self.posts addObjectsFromArray:array];
             self.skipCount = self.skipCount + 30;
             [self.tableView reloadData];
         }];
    }
}


- (CustomFeedTableViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    }
    return _prototypeCell;
}

- (CustomFeedWithPhotoTableViewCell *)photoPrototypeCell
{
    if (!_photoPrototypeCell)
    {
        _photoPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"CellWithImage"];
    }
    return _photoPrototypeCell;
}


- (IBAction)createPostButtonPressed:(UIBarButtonItem *)button
{
    if ([User currentUser])
    {
        [self performSegueWithIdentifier:@"createPost" sender:button];
    }
    else
    {
        [self performSegueWithIdentifier:@"loginFirst" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Photo"] || [segue.identifier isEqualToString:@"NoPhoto"])
     {
         PostDetailViewController *vc = segue.destinationViewController;
         Post *post = self.posts[self.tableView.indexPathForSelectedRow.row];
         vc.post = post;
     }
}


@end
