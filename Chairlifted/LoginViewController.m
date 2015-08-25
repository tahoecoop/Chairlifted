//
//  LoginViewController.m
//  Chairlifted
//
//  Created by Bradley Justice on 8/23/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) NSArray *friendsArray;


@end



@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{

    if ([FBSDKAccessToken currentAccessToken])
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
        {

             [User logInWithUsername:result[@"name"] password:result[@"id"]];

             if ([User currentUser])
             {
                 [self dismissViewControllerAnimated:YES completion:nil];
             }

         }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsArray = [NSArray new];

    if ([FBSDKAccessToken currentAccessToken])
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
        {
             if (!error)
             {
                 NSLog(@"fetched user:%@", result);

             }
         }];
    }
}



- (IBAction)onFBLoginPressed:(UIButton *)sender
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];


    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"user_friends", @"email", @"user_about_me"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         if (error)
         {
             NSLog(@"Process error");
         }
         else if (result.isCancelled)
         {
             NSLog(@"Cancelled");
         }
         else
         {
             NSLog(@"Logged in");

             if ([FBSDKAccessToken currentAccessToken])
             {
                 [[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email, picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                  {
                      NSLog(@"%@", result);

                      [User logInWithUsername:result[@"name"] password:result[@"id"]];
                      [self dismissViewControllerAnimated:YES completion:nil];

                      NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://graph.facebook.com/\%@/picture?type=large&return_ssl_resources=1", result[@"id"]]];

                      UIImage *displayPicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:url] scale:1.0];

                      self.friendsArray = [NSArray arrayWithArray:[[result valueForKey:@"friends"] valueForKey:@"data"]];


                      User *user = [User new];

                      user.username = result[@"name"];
                      user.password = result[@"id"];
                      user.email = result[@"email"];
                      user.profileImage = [PFFile fileWithData:UIImageJPEGRepresentation(displayPicture, 1.0)];
                      user.friends = self.friendsArray;

                      [user signUpInBackgroundWithBlock:^(BOOL success, NSError *error)
                       {
                           if (success)
                           {
                               [activityView removeFromSuperview];
                           }
                       }];
                      
                      if (error)
                      {
                          
                      }
                      
                  }];
             }
         }
     }];
}


- (IBAction)onParseLoginButtonPressed:(UIButton *)button
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];


    [User logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error)
    {
        if ([User currentUser])
        {
            [activityView removeFromSuperview];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (error)
        {
//            UIAlertController *loginErrorAlert = 
        }
    }];
}



@end










































