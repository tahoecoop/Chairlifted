
//  CreateNewUserViewController.m
//  Chairlifted
//
//  Created by Bradley Justice on 8/25/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateNewUserViewController.h"
#import "User.h"
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIAlertController+ErrorAlert.h"


@interface CreateNewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;


@end

@implementation CreateNewUserViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    // Do any additional setup after loading the view.

}


- (IBAction)onCreateUserButtonPressed:(UIButton *)sender

{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];

    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];

    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];

    [activityView addSubview:spinnerImageView];

    [self.view addSubview:activityView];

    [spinnerImageView rotateLayerInfinite];

    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    User *user = [User new];

    user.username = username;
    user.password = password;
    user.displayName = username;
    user.email = email;

    [user saveInBackgroundWithBlock:^(BOOL success, NSError *error)
     {
         [activityView removeFromSuperview];

         if (error)
         {
             UIAlertController *alert = [UIAlertController showErrorAlert:error orMessage:nil];
             [self presentViewController:alert animated:YES completion:nil];
         }
         else
         {
            [self dismissViewControllerAnimated:YES completion:nil];
         }
     }];
}





@end

