//
//  DetailActionTableViewCell.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "DetailActionTableViewCell.h"

@implementation DetailActionTableViewCell

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)onLikeButtonPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Like"])
    {
        self.like = [Like new];
        self.like.liker = [User currentUser];
        self.like.post = self.post;
        [self.like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 self.post.likeCount++;
                 [self.post calculateHottness];
                 [self.post saveInBackgroundWithBlock:^(BOOL succeededTwo, NSError *error)
                  {
                      if (succeededTwo)
                      {
                          [self checkIfLiked];
                          [self.parentTableView reloadData];
                      }
                  }];
             }
         }];
    }
    else
    {
        [self.like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 self.like = nil;
                 self.post.likeCount--;
                 [self.post calculateHottness];
                 [self.post saveInBackgroundWithBlock:^(BOOL succeededTwo, NSError *error)
                  {
                      if (succeededTwo)
                      {
                          [self checkIfLiked];
                          [self.parentTableView reloadData];

                      }
                  }];
             }
         }];
    }
}


- (IBAction)onCommentButtonPressed:(UIButton *)sender
{
    
}


- (void)checkIfLiked
{
    [NetworkRequests getLikes:self.post withCompletion:^(NSArray *array)
     {
         if (array.count > 0)
         {
             [NetworkRequests checkForLike:self.post withCompletion:^(NSArray *arrayTwo)
             {
                 if (arrayTwo.count > 0)
                 {
                     self.like = arrayTwo[0];
                     [self.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
                 }
                 else
                 {
                     [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
                 }
             }];
         }
         else
         {
             [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
         }
     }];
}
@end
