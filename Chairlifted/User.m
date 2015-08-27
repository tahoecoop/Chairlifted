//
//  User.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic username;
@dynamic displayName;
@dynamic email;
@dynamic friends;
@dynamic favoriteResorts;
@dynamic posts;
@dynamic runs;
@dynamic profileImage;
@dynamic name;
@dynamic favoriteResort;
@dynamic location;
@dynamic isSnowboarder;

+ (void)load
{
    [self registerSubclass];
}


@end
