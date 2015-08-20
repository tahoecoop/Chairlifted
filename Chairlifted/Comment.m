//
//  Comment.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic author;
@dynamic text;
@dynamic createdAt;
@dynamic post;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Comment";
}



@end
