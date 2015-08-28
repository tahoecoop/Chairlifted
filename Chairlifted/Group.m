//
//  Group.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/20/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "Group.h"

@implementation Group

@dynamic name;
@dynamic isPrivate;
@dynamic mostRecentPost;
@dynamic memberQuantity;
@dynamic purpose;
@dynamic image;
@dynamic imageThumbnail;



+ (void)load
{
    [self registerSubclass];
}


+ (NSString *)parseClassName
{
    return @"Group";
}



@end
