//
//  GroupFeedViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "JoinGroup.h"
#import "GroupFeedHeaderTableViewCell.h"

@interface GroupFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JoinGroupEditDelegate>

@property (nonatomic) Group *group;
@property (nonatomic) JoinGroup *joinGroup;

@end
