//
//  User.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic name;
@dynamic username;
@dynamic email;
@dynamic friends;
@dynamic favoriteResorts;
@dynamic posts;
@dynamic runs;

+ (void)load
{
    [self registerSubclass];
}


@end
