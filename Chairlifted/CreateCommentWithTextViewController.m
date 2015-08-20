//
//  CreateCommentWithTextViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateCommentWithTextViewController.h"
#import "Comment.h"

@interface CreateCommentWithTextViewController ()

@end

@implementation CreateCommentWithTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPostInComments];

}


- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    Comment *comment = [Comment new];
    comment.text = self.textView.text;
    comment.author = [User currentUser];
    comment.post = self.post;

//    [self.post.comments addObject:comment];
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
                      [self dismissViewControllerAnimated:YES completion:nil];
                  }
              }];
         }
     }];
}

- (void)setUpPostInComments
{
    self.postTitleLabel.text = self.post.title;
    self.postTextLabel.text = self.post.text;
    [self.textView becomeFirstResponder];
}

@end
