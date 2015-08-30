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
#import "UIAlertController+ErrorAlert.h"
#import <AFNetworkReachabilityManager.h>

@interface FeedViewController ()

@property (nonatomic) NSMutableArray *posts;
@property (nonatomic) CustomFeedTableViewCell *prototypeCell;
@property (nonatomic) CustomFeedWithPhotoTableViewCell *photoPrototypeCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int skipCount;
@property (nonatomic) BOOL continueLoading;
@property (weak, nonatomic) IBOutlet UIView *cardView;

// Pull to refresh properties
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *rightFlake;
@property (nonatomic, strong) UIImageView *leftFlake;
@property (assign) BOOL isFlakesOverlap;
@property (assign) BOOL isAnimating;


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

    [self setupRefreshControl];
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
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:75.0/255.0 green:171.0/255.0 blue:253.0/255.0  alpha:1.0];

    self.skipCount = 30;
    [NetworkRequests getPostsWithSkipCount:0 andGroup:nil andIsPrivate:NO completion:^(NSArray *array)
     {
         self.posts = [NSMutableArray arrayWithArray:array];
         [self.tableView reloadData];
     }];

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
        textCell.repliesLabel.text = [NSString stringWithFormat:@"%i", (int)post.commentCount];
        textCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
        textCell.likesLabel.text = [NSString stringWithFormat:@"%i", post.likeCount];

        [textCell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
        [textCell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
        [textCell.cardView.layer setShadowRadius:2.0];
        [textCell.cardView.layer setShadowOpacity:0.5];
    }
    else if ([cell isKindOfClass:[CustomFeedWithPhotoTableViewCell class]])
    {
        CustomFeedWithPhotoTableViewCell *textCell = (CustomFeedWithPhotoTableViewCell *)cell;
        Post *post = self.posts[indexPath.row];
        textCell.titleLabel.text = post.title;
        textCell.authorLabel.text = post.author.displayName;
        textCell.repliesLabel.text = [NSString stringWithFormat:@"%i", (int)post.commentCount];
        textCell.minutesAgoLabel.text = [NSDate determineTimePassed:post.createdAt];
        textCell.likesLabel.text = [NSString stringWithFormat:@"%i", post.likeCount];

        [textCell.cardView.layer setShadowColor:[UIColor blackColor].CGColor];
        [textCell.cardView.layer setShadowOffset:CGSizeMake(0, 2)];
        [textCell.cardView.layer setShadowRadius:2.0];
        [textCell.cardView.layer setShadowOpacity:0.5];

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

#pragma mark - Pull to refresh methods

- (void)setupRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.backgroundColor = [UIColor blueColor];
    self.refreshColorView.alpha = 0.30;

    self.rightFlake = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flake1.png"]];
    self.leftFlake = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flake1.png"]];
    [self.refreshLoadingView addSubview:self.leftFlake];
    [self.refreshLoadingView addSubview:self.rightFlake];

    self.refreshLoadingView.clipsToBounds = YES;
    self.refreshControl.tintColor = [UIColor clearColor];
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];

    self.isFlakesOverlap = NO;
    self.isAnimating = NO;

    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}


- (void)refresh:(id)sender
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect refreshBounds = self.refreshControl.bounds;
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    CGFloat midX = self.tableView.frame.size.width / 2.0;

    CGFloat rightFlakeHeight = self.rightFlake.bounds.size.height;
    CGFloat rightFlakeHeightHalf = rightFlakeHeight / 2.0;
    CGFloat rightFlakeWidth = self.rightFlake.bounds.size.width;
    CGFloat rightFlakeWidthHalf = rightFlakeWidth / 2.0;
    CGFloat leftFlakeHeight = self.leftFlake.bounds.size.height;
    CGFloat leftFlakeHeightHalf = leftFlakeHeight / 2.0;
    CGFloat leftFlakeWidth = self.leftFlake.bounds.size.width;
    CGFloat leftFlakeWidthHalf = leftFlakeWidth / 2.0;

    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    CGFloat rightFlakeY = pullDistance / 2.0 - rightFlakeHeightHalf;
    CGFloat leftFlakeY = pullDistance / 2.0 - leftFlakeHeightHalf;
    CGFloat rightFlakeX = (midX + rightFlakeWidthHalf) - (rightFlakeWidth * pullRatio);
    CGFloat leftFlakeX = (midX - leftFlakeWidth - leftFlakeWidthHalf) + (leftFlakeWidth * pullRatio);

    if (fabs(rightFlakeX - leftFlakeX) < 1.0)
    {
        self.isFlakesOverlap = YES;
    }

    if (self.isFlakesOverlap || self.refreshControl.isRefreshing)
    {
        rightFlakeX = midX - rightFlakeWidthHalf;
        leftFlakeX = midX - leftFlakeWidthHalf;
    }

    CGRect rightFlakeFrame = self.rightFlake.frame;
    rightFlakeFrame.origin.x = rightFlakeX;
    rightFlakeFrame.origin.y = rightFlakeY;

    CGRect leftFlakeFrame = self.leftFlake.frame;
    leftFlakeFrame.origin.x= leftFlakeX;
    leftFlakeFrame.origin.y = leftFlakeY;

    self.rightFlake.frame = rightFlakeFrame;
    self.leftFlake.frame = leftFlakeFrame;

    refreshBounds.size.height = pullDistance;
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;

    if (self.refreshControl.isRefreshing && !self.isAnimating)
    {
        [self animateRefreshView];
    }
}


- (void)animateRefreshView
{
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    self.isAnimating = YES;

    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.leftFlake setTransform:CGAffineTransformRotate(self.leftFlake.transform, M_PI_2)];
                         [self.rightFlake setTransform:CGAffineTransformRotate(self.rightFlake.transform, -M_PI_2)];
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished)
                     {
                         if (self.refreshControl.isRefreshing)
                         {
                             [self animateRefreshView];
                         }
                         else
                         {
                             [self resetAnimation];
                         }
                     }];
}


- (void)resetAnimation
{
    self.isAnimating = NO;
    self.isFlakesOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor blueColor];
}


#pragma mark - Actions

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

#pragma mark - Prepare for segue

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
