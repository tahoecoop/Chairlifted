//
//  Resort.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "Resort.h"

@implementation Resort


@dynamic name;
@dynamic country;
@dynamic latitude;
@dynamic longitude;


+ (void)load
{
    [self registerSubclass];
}


+ (NSString *)parseClassName
{
    return @"Resort";
}



@end

