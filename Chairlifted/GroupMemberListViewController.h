//
//  GroupMemberListViewController.h
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "GroupMemberRespondRequestCellTableViewCell.h"

@interface GroupMemberListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AcceptedOrDeniedDelegate>

@property (nonatomic) Group *group;
@property (nonatomic) JoinGroup *joinGroup;

@end
