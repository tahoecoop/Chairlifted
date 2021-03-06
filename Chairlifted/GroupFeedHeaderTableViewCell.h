//
//  GroupFeedHeaderTableViewCell.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "JoinGroup.h"

@protocol JoinGroupEditDelegate;

@interface GroupFeedHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupPurposeLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestToJoinButton;
@property (nonatomic) Group *group;
@property (nonatomic) JoinGroup *joinGroup;
@property (strong, nonatomic) IBOutlet UIButton *createNewPostButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (nonatomic) id<JoinGroupEditDelegate> delegate;

@end

@protocol JoinGroupEditDelegate <NSObject>

-(void)didEditJoinGroup;

@end
