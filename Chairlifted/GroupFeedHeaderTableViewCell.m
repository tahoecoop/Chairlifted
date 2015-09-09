//
//  GroupFeedHeaderTableViewCell.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "GroupFeedHeaderTableViewCell.h"
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"

@implementation GroupFeedHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)requestToJoinPressed:(UIButton *)button
{
   if (![button.titleLabel.text isEqualToString:@"Pending"] && ![button.titleLabel.text isEqualToString:@"Admin"])
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        UIView *activityView = [[UIView alloc] initWithFrame:screenRect];
        activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenRect.size.width / 2) - 15, (screenRect.size.height / 2) - 15, 30, 30)];
        spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
        [activityView addSubview:spinnerImageView];
        [self addSubview:activityView];
        [spinnerImageView rotateLayerInfinite];

        if ([button.titleLabel.text isEqualToString:@"Join"])
        {
            if ([self.group.isPrivate boolValue])
            {
                JoinGroup *joinGroup = [JoinGroup new];
                joinGroup.user = [User currentUser];
                joinGroup.group = self.group;
                joinGroup.groupName = self.group.name;
                joinGroup.userUsername = [[User currentUser].displayName lowercaseString];
                joinGroup.status = @"pending";
                [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (succeeded)
                     {
                         NSDictionary *pushData = @{
                                                    @"alert" : [NSString stringWithFormat:@"%@ requested to join \"%@\"!", [User currentUser].displayName, self.group.name],
                                                    @"badge" : @"Increment"
                                                    };

                         PFPush *push = [PFPush new];
                         [push setChannel:[NSString stringWithFormat:@"admin%@",self.group.objectId]];
                         [push setData:pushData];

                         [push sendPushInBackground];

                         
                         PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                         [currentInstallation addUniqueObject:[NSString stringWithFormat:@"group%@request%@", self.group.objectId, [User currentUser].displayName] forKey:@"channels"];

                         [activityView removeFromSuperview];
                         [button setTitle:@"Pending" forState:UIControlStateNormal];
                         [self.delegate didEditJoinGroup];
                     }
                 }];
            }
            else
            {
                JoinGroup *joinGroup = [JoinGroup new];
                joinGroup.user = [User currentUser];
                joinGroup.group = self.group;
                joinGroup.status = @"joined";
                joinGroup.lastViewed = [NSDate date];
                joinGroup.groupName = self.group.name;
                joinGroup.userUsername = [[User currentUser].displayName lowercaseString];
                [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (succeeded)
                     {
                         self.group.memberQuantity++;
                         [self.group saveInBackgroundWithBlock:^(BOOL succeededTwo, NSError *error)
                          {
                              if (succeededTwo)
                              {
                                  [activityView removeFromSuperview];
                                  [button setTitle:@"Leave group" forState:UIControlStateNormal];
                                  [self.delegate didEditJoinGroup];
                              }
                          }];
                     }
                 }];
            }
        }
        else if ([button.titleLabel.text isEqualToString:@"Leave group"])
        {
            [self.joinGroup deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (succeeded)
                 {
                     self.group.memberQuantity--;
                     [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                      {
                          if (succeeded)
                          {
                              [activityView removeFromSuperview];
                              [button setTitle:@"Join" forState:UIControlStateNormal];
                              [self.delegate didEditJoinGroup];
                          }
                      }];
                 }
             }];
        }
    }
}

@end
