//
//  Post.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "Post.h"

@implementation Post

@dynamic user;
@dynamic text;
@dynamic title;
@dynamic image;
@dynamic comments;
@dynamic createdAt;
@dynamic voteCount;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Post";
}



@end
