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

@interface FeedViewController ()

@property (nonatomic) NSMutableArray *posts;

@end

@implementation FeedViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated
{
    if (![PFUser currentUser])
    {
        PFLogInViewController *loginVC = [PFLogInViewController new];
        loginVC.delegate = self;
        PFSignUpViewController *signupVC = [PFSignUpViewController new];
        signupVC.delegate = self;

        [loginVC setSignUpController:signupVC];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}


#pragma mark - Parse Delegate Methods

- (void)signUpViewController:(PFSignUpViewController * __nonnull)signUpController didSignUpUser:(PFUser * __nonnull)user
{
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             [signUpController dismissViewControllerAnimated:YES completion:nil];
         }
     }];
}

-(void)logInViewController:(PFLogInViewController * __nonnull)logInController didLogInUser:(PFUser * __nonnull)user
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
    CustomFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height;
    
    return height;
}

- (void)configureCell:(CustomFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomFeedTableViewCell *postCell = (CustomFeedTableViewCell *)cell;

}


@end
