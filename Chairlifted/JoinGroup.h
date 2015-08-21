//
//  JoinGroup.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/20/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import "Group.h"
#import "User.h"

@interface JoinGroup : PFObject <PFSubclassing>

@property (nonatomic) Group *group;
@property (nonatomic) User *user;
@property (nonatomic) NSString *status;
@property (nonatomic) NSDate *lastViewed;
@property (nonatomic) NSString *groupName;

+ (void)load;
+ (NSString *)parseClassName;

@end
