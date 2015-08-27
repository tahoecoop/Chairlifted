//
//  JoinGroup.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/20/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "JoinGroup.h"

@implementation JoinGroup

@dynamic group;
@dynamic user;
@dynamic status;
@dynamic lastViewed;
@dynamic groupName;
@dynamic  userUsername;


+ (void)load
{
    [self registerSubclass];
}


+ (NSString *)parseClassName
{
    return @"JoinGroup";
}


@end
