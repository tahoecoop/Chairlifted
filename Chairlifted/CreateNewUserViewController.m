//
//  CreateNewUserViewController.m
//  Chairlifted
//
//  Created by Bradley Justice on 8/25/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateNewUserViewController.h"
#import "User.h"

@interface CreateNewUserViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CreateNewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onCreateUserButtonPressed:(UIButton *)sender {
    User *user = [User new];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;

    [user save];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
