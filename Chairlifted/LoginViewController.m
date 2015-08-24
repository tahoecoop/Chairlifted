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

@end



@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated {

    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

             [PFUser logInWithUsername:result[@"name"] password:result[@"id"]];

             if ([User currentUser]) {
                 [self performSegueWithIdentifier:@"autoLogin" sender:self];
             }

         }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];


    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);

             }
         }];
    }

    UIButton *fbLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    fbLoginButton.backgroundColor=[UIColor darkGrayColor];
    fbLoginButton.frame=CGRectMake(0,0,180,40);
    fbLoginButton.center = self.view.center;
    [fbLoginButton setTitle: @"Login With Facebook" forState: UIControlStateNormal];

    // Handle clicks on the button
    [fbLoginButton
     addTarget:self
     action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    // Add the button to the view
    [self.view addSubview:fbLoginButton];


}


-(void)loginButtonClicked
{


    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"user_friends", @"email", @"user_about_me"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");

            if ([FBSDKAccessToken currentAccessToken]) {
                     [[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email, picture.width(100).height(100)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                         NSLog(@"%@", result);

                         [PFUser logInWithUsername:result[@"name"] password:result[@"id"]];
                         [self performSegueWithIdentifier:@"autoLogin" sender:self];

                         NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://graph.facebook.com/\%@/picture?type=large&return_ssl_resources=1", result[@"id"]]];

                         UIImage *displayPicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:url] scale:1.0];

                         NSArray *friendsArray = [NSArray arrayWithArray:[[result valueForKey:@"frieds"] valueForKey:@"data"]];


                         User *user = [User new];

                         user.username = result[@"name"];
                         user.password = result[@"id"];
                         user.email = result[@"email"];
                         user.profileImage = [PFFile fileWithData:UIImageJPEGRepresentation(displayPicture, 1.0)];

                         [user signUpInBackground];



                         if (error) {
                             [PFUser logInWithUsername:result[@"email"] password:result[@"id"]];
                             [self performSegueWithIdentifier:@"autoLogin" sender:self];

                         }

                     }];

             }
         }
     }];
}


- (IBAction)onParseLoginButtonPressed:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text];
    if ([User currentUser]) {
        [self performSegueWithIdentifier:@"autoLogin" sender:self];
    }
}



@end










































