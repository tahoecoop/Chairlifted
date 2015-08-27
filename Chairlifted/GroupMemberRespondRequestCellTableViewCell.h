//
//  GroupMemberRespondRequestCellTableViewCell.h
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoinGroup.h"


@protocol AcceptedOrDeniedDelegate;

@interface GroupMemberRespondRequestCellTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic) JoinGroup *joinGroup;
@property (strong, nonatomic) IBOutlet UIButton *denyButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;

@property (nonatomic, weak) IBOutlet id<AcceptedOrDeniedDelegate> delegate;

@end

@protocol AcceptedOrDeniedDelegate <NSObject>

-(void)buttonWasTapped;

@end
