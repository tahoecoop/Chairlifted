//
//  PostTopic.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/20/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "PostTopic.h"

@implementation PostTopic

@dynamic name;

+ (void)load
{
    [self registerSubclass];
}


+ (NSString *)parseClassName
{
    return @"PostTopic";
}


@end
