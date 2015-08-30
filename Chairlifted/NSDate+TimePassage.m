//
//  NSDate+TimePassage.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "NSDate+TimePassage.h"


@implementation NSDate (TimePassage)

+ (NSString *)determineTimePassed:(NSDate *)date
{
    NSTimeInterval timeInterval = fabs([date timeIntervalSinceNow]);
    int minutes = timeInterval / 60;
    int hours = minutes / 60;
    int days = hours / 24;


    if (date == nil)
    {
        return @"";
    }
    else if (minutes < 1)
    {
        return @"now";
    }
    else if (hours < 1)
    {
        return [NSString stringWithFormat:@"%im", minutes];
    }
    else if (days < 1)
    {
        return [NSString stringWithFormat:@"%ih", hours];
    }
    else
    {
        return [NSString stringWithFormat:@"%id", days];
    }
}

@end
