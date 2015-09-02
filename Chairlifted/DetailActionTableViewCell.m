//
//  DetailActionTableViewCell.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "DetailActionTableViewCell.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"

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
    if ([User currentUser])
    {
        UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width / 2) - 15, (self.frame.size.height / 2) - 15, 30, 30)];
        spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
        [activityView addSubview:spinnerImageView];
        [self addSubview:activityView];
        [spinnerImageView rotateLayerInfinite];

        if ([sender.imageView.image isEqual:[UIImage imageNamed:@"heartEmptyIcon.pdf"]])
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

                              PFQuery *pushQuery = [PFInstallation query];
                              [pushQuery whereKey:@"user" equalTo:self.post.author];

                              NSDictionary *pushData = @{@"alert" : [NSString stringWithFormat:@"%@ liked your post!", [User currentUser].displayName],
                                                         @"badge" : @"Increment"};
                              PFPush *push = [PFPush new];
                              [push setData:pushData];
                              [push setQuery:pushQuery];
                              [push sendPushInBackgroundWithBlock:^(BOOL succeededPush, NSError *error)
                               {
                                   if (succeededPush)
                                   {
                                       [activityView removeFromSuperview];
                                       [self.parentTableView reloadData];
                                   }
                               }];
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
                              [activityView removeFromSuperview];
                              [self.parentTableView reloadData];
                          }
                      }];
                 }
             }];
        }
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
             if ([User currentUser])
             {
                 [NetworkRequests checkForLike:self.post withCompletion:^(NSArray *arrayTwo)
                  {
                      if (arrayTwo.count > 0)
                      {
                          self.like = arrayTwo[0];
                          [self.likeButton setImage:[UIImage imageNamed:@"heartFullIcon.pdf"] forState:UIControlStateNormal];
                      }
                      else
                      {
                          self.likeButton.imageView.image = [UIImage imageNamed:@"heartEmptyIcon.pdf"];
                      }
                  }];
             }
             else
             {
                 self.likeButton.imageView.image = [UIImage imageNamed:@"heartEmptyIcon.pdf"];
             }
         }
     }];
}
@end
