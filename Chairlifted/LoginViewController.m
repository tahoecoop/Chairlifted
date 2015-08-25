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



- (IBAction)onFBLoginPressed:(UIButton *)sender {
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

                      [user signUpInBackground];
                      
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
    [User logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error)
    {
        if ([User currentUser])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (error) {
//            UIAlertController *loginErrorAlert = 
        }
    }];
}



@end










































