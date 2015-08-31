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
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "UIAlertController+ErrorAlert.h"
#import "NetworkRequests.h"
#import "UIAlertController+ErrorAlert.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import "CreateNewUserViewController.h"


@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) NSArray *displayNames;


@end


@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    if ([User currentUser]) {

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];

    return NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}


- (IBAction)didClickOnPresent:(id)sender {

    CreateNewUserViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"createNewUser"];

    modalVC.transitioningDelegate = self;

    modalVC.modalPresentationStyle = UIModalPresentationCustom;

    [self presentViewController:modalVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitionDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[DismissingAnimationController alloc] init];
}



- (IBAction)onFBLoginPressed:(UIButton *)sender
{
    NSArray *permissionsArray = @[ @"user_about_me", @"user_birthday", @"user_location", @"user_friends", @"email", @"public_profile"];

    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error)
     {
         if (!error)
         {

             if (!user)
             {

                 NSString *errorMessage = nil;

                 if (!error)
                 {

                     NSLog(@"Uh oh. The user cancelled the Facebook login.");

                     errorMessage = @"Uh oh. The user cancelled the Facebook login.";
                 }
                 else
                 {

                     NSLog(@"Uh oh. An error occurred: %@", error);

                     errorMessage = [error localizedDescription];
                 }

                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                 message:errorMessage
                                                                delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"Dismiss", nil];
                 [alert show];
             }
             else
             {
                 if (user.isNew)
                 {

                     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, friends, email"}]

                      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                      {
                          NSLog(@"%@",result);

                          NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://graph.facebook.com/\%@/picture?type=large&return_ssl_resources=1", result[@"id"]]];

                          UIImage *displayPicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:url] scale:1.0];

                          user[@"profileImage"] = [PFFile fileWithData:UIImageJPEGRepresentation(displayPicture, 1.0)];

                          user[@"friends"] = [NSArray arrayWithArray:[[result valueForKey:@"friends"] valueForKey:@"data"]];
                      }];

                     UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Choose a dsiplay name" message:@"Choose your display name." preferredStyle:UIAlertControllerStyleAlert];
                     [vc addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                         textField.placeholder = @"Display Name";
                     }];
                     UITextField *dName = [[vc textFields]firstObject];

                     UIAlertAction *set = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                       {
                           UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                           activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
                           UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
                           spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
                           [activityView addSubview:spinnerImageView];
                           [self.view addSubview:activityView];
                           [spinnerImageView rotateLayerInfinite];

                           [NetworkRequests getDisplayNamesWithDisplayName:dName.text Completion:^(NSArray *array)
                           {
                               self.displayNames = array;

                               if ([self.displayNames.firstObject[@"displayName"] isEqualToString:[NSString stringWithFormat:@"%@",dName.text]])
                               {
                                   UIAlertController *takenDisplayNameAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"This display name is taken." preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       [self presentViewController:vc animated:YES completion:nil];
                                   }];
                                   [takenDisplayNameAlert addAction:okay];
                                   [activityView removeFromSuperview];
                                   [self presentViewController:takenDisplayNameAlert animated:YES completion:nil];
                               }
                               else
                               {
                                   user[@"displayName"] = dName.text;
                                   [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                    {
                                        NSLog(@"%@", user);
                                        [activityView removeFromSuperview];
                                        [self performSegueWithIdentifier:@"newUser" sender:set];
                                    }];
                               }
                           }];
                       }];

                     [vc addAction:set];
                     [self presentViewController:vc animated:YES completion:nil];

                     NSLog(@"User with facebook signed up and logged in!");

                 }
                 else
                 {

                     NSLog(@"User with facebook logged in!");
                     [self dismissViewControllerAnimated:YES completion:nil];

                 }
             }

         }
         else
         {
             UIAlertController *alert = [UIAlertController showErrorAlert:error orMessage:nil];
             [self presentViewController:alert animated:YES completion:nil];
             NSLog(@"%@", error);
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
         if (error)
         {
             UIAlertController *alert = [UIAlertController showErrorAlert:error orMessage:nil];
             [self presentViewController:alert animated:YES completion:nil];
         }
         if ([User currentUser])
         {
             [activityView removeFromSuperview];
             
             [self dismissViewControllerAnimated:YES completion:nil];
         }

     }];
}


- (IBAction)onForgotPasswordButtonPressed:(UIButton *)sender
{
    
    UIAlertController *forgotPasswordAlert = [UIAlertController alertControllerWithTitle:@"Reset Password" message:@"Reset your password by enterting the associated email below." preferredStyle:UIAlertControllerStyleAlert];
    
    [forgotPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.placeholder = @"Email";
    }];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        UITextField *emailForForgotten = [[forgotPasswordAlert textFields]firstObject];

        [PFUser requestPasswordResetForEmailInBackground:emailForForgotten.text block:^(BOOL succeded, NSError *error)
        {
            if (error)
            {
                UIAlertController *alert = [UIAlertController showErrorAlert:error orMessage:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
    }];
    
    [forgotPasswordAlert addAction:submit];
    [forgotPasswordAlert addAction:dismiss];

    [self presentViewController:forgotPasswordAlert animated:YES completion:nil];
    
}





@end

