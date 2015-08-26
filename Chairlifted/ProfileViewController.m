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
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"
#import "EditProfileViewController.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, updatedResortDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) NSMutableArray *myPosts;
@property (nonatomic) int skipCount;
@property (nonatomic) NSDictionary *weatherDict;
@property (nonatomic) Resort *resort;
@property (nonatomic) BOOL shouldUpdateResort;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.skipCount = 0;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shouldUpdateResort = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setUpUser];
}

- (void)setUpUser
{
    if (![User currentUser])
    {
        if (![User currentUser])
        {
            [self performSegueWithIdentifier:@"loginBeforeProfile" sender:self];
            self.shouldUpdateResort = NO;
        }
    }
    else if (!self.selectedUser || [self.selectedUser isEqual:[User currentUser]])
    {
        self.selectedUser = [User currentUser];
        self.shouldUpdateResort = YES;
    }
    else
    {
        self.editButton.enabled = NO;
        self.editButton.tintColor = [UIColor clearColor];
        self.title = self.selectedUser.username;
        self.shouldUpdateResort = YES;
    }


    if (self.shouldUpdateResort)
    {
        UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
        spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
        [activityView addSubview:spinnerImageView];
        [self.view addSubview:activityView];
        [spinnerImageView rotateLayerInfinite];

        self.resort = self.selectedUser.favoriteResort;
        [self.resort fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             [NetworkRequests getWeatherFromLatitude:self.resort.latitude andLongitude:self.resort.longitude andCompletion:^(NSDictionary *dictionary)
              {
                  self.weatherDict = dictionary;
                  [NetworkRequests getPostsWithSkipCount:self.skipCount andUser:self.selectedUser andShowsPrivate:[self.selectedUser isEqual:[User currentUser]] completion:^(NSArray *array)
                   {
                       self.myPosts = [NSMutableArray arrayWithArray:array];
                       [activityView removeFromSuperview];
                       self.shouldUpdateResort = NO;
                       [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                   }];
              }];
         }];
    }
    else
    {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![User currentUser])
    {
        return 0;
    }
    else if (section == 0)
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
        if (self.resort && self.weatherDict)
        {
            headerCell.weatherLabel.text = [NSString stringWithFormat:@"%.2f", [self.weatherDict[@"temperature"] floatValue]];
            headerCell.weatherIconImageView.image = [UIImage imageNamed:self.weatherDict[@"icon"]];
            headerCell.locationLabel.text = self.resort.name;
        }

        PFFile *imageData = self.selectedUser.profileImage;
        [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             headerCell.profileImageView.image = [UIImage imageWithData:data scale:0.7];
         }];

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

            PFFile *imageData = post.image;
            [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
             {
                 cell.postImageView.image = [UIImage imageWithData:data scale:0.3];
             }];

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

-(void)didUpdateResort
{
    self.shouldUpdateResort = YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditProfile"])
    {
        EditProfileViewController *vc = (EditProfileViewController *)[segue.destinationViewController topViewController];
        vc.delegate = self;
    }
}








@end
