//
//  GroupMemberRespondRequestCellTableViewCell.m
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import "GroupMemberRespondRequestCellTableViewCell.h"

@implementation GroupMemberRespondRequestCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)denyButtonPressed:(UIButton *)button
{
    [self.joinGroup deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        Group *group = self.joinGroup.group;
        [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             group.memberQuantity--;
             [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  [self.delegate buttonWasTapped];
              }];
         }];
    }];
}


- (IBAction)acceptButtonPressed:(UIButton *)button
{
    self.joinGroup.status = @"joined";
    [self.joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            Group *group = self.joinGroup.group;
            [group fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
            {
                group.memberQuantity++;
                [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                {
                    [self.delegate buttonWasTapped];
                }];
            }];
        }
    }];
}


@end
