//
//  CreateCommentWithImageViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateCommentWithImageViewController.h"
#import "Comment.h"

@interface CreateCommentWithImageViewController ()

@end

@implementation CreateCommentWithImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPostInComments];
    // Do any additional setup after loading the view.
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
    self.postBodyLabel.text = self.post.text;
    self.commentImageView.image = [UIImage imageWithData:self.post.image.getData];
    [self.textView becomeFirstResponder];
}
@end
