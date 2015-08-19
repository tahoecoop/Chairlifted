//
//  Run.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "Run.h"

@implementation Run

@dynamic relativeAltitude;
@dynamic speed;
@dynamic timeOfRun;
@dynamic topSpeed;
@dynamic avgSpeed;
@dynamic distanceTraveled;



+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Run";
}



@end
