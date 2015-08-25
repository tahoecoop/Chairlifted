//
//  GroupFeedHeaderTableViewCell.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "GroupFeedHeaderTableViewCell.h"

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
    if ([button.titleLabel.text isEqualToString:@"Join"])
    {
        if ([self.group.isPrivate boolValue])
        {
            JoinGroup *joinGroup = [JoinGroup new];
            joinGroup.user = [User currentUser];
            joinGroup.group = self.group;
            joinGroup.groupName = self.group.name;
            joinGroup.status = @"pending";
            [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (succeeded)
                {
                    [button setTitle:@"Pending" forState:UIControlStateNormal];
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
            [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (succeeded)
                {
                    self.group.memberQuantity++;
                    [self.group saveInBackgroundWithBlock:^(BOOL succeededTwo, NSError *error)
                    {
                        if (succeededTwo)
                        {
                            [button setTitle:@"Leave group" forState:UIControlStateNormal];
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
                        [button setTitle:@"Join" forState:UIControlStateNormal];
                    }
                }];
            }
        }];
    }
}

@end
