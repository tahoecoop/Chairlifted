//
//  CreateCommentWithImageViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateCommentWithImageViewController.h"
#import "Comment.h"
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import <pop/POP.h>
#import "PostDetailViewController.h"

@interface CreateCommentWithImageViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CreateCommentWithImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPostInComments];
    self.view.layer.cornerRadius = 10.f;

}

-(void)viewWillAppear:(BOOL)animated
{
    self.cancelButton.layer.cornerRadius = 10.f;
    [self.cancelButton setBackgroundColor:[UIColor redColor]];

    self.postButton.layer.cornerRadius = 10.f;
    [self.postButton setBackgroundColor:[UIColor greenColor]];

    self.textView.layer.cornerRadius = 5.f;
}


- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveButtonPressed:(UIButton *)sender
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];


    Comment *comment = [Comment new];
    comment.text = self.textView.text;
    comment.author = [User currentUser];
    comment.post = self.post;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             self.post.commentCount++;
             [self.post calculateHottness];
             [self.post saveInBackgroundWithBlock:^(BOOL succeededTwo, NSError *error)
              {
                  if (succeededTwo)
                  {
                      NSDictionary *pushData = @{@"alert" : [NSString stringWithFormat:@"%@ commented on your post!", [User currentUser].displayName],
                                                 @"badge" : @"Increment"};
                      PFPush *push = [PFPush new];
                      [push setChannel:[NSString stringWithFormat:@"comments%@",self.post.author.objectId]];
                      [push setData:pushData];

                      [push sendPushInBackgroundWithBlock:^(BOOL succeededPush, NSError *error)
                       {
                           if (succeededPush)
                           {
                               [activityView removeFromSuperview];
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }
                       }];
                  }
              }];
         }
     }];

}

- (void)setUpPostInComments
{
    self.postTitleLabel.text = self.post.title;
    self.postBodyLabel.text = self.post.text;

    PFFile *imageData = self.post.image;
    [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
     {
         self.commentImageView.image = [UIImage imageWithData:data scale:0.7];
     }];
    [self.textView becomeFirstResponder];
}


@end
