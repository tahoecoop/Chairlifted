//
//  IntroViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 9/2/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onStartButtonPressed:(UIBarButtonItem *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenIntro"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
