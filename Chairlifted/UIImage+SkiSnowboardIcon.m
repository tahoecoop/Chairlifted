//
//  UIImage+SkiSnowboardIcon.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/25/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "UIImage+SkiSnowboardIcon.h"
#import "User.h"

@implementation UIImage (SkiSnowboardIcon)

+ (UIImage *)returnSkierOrSnowboarderImage:(BOOL)isSnowboarder
{
    if (isSnowboarder)
    {
        return [UIImage imageNamed:@"boarder"];
    }
    else
    {
        return [UIImage imageNamed:@"skier"];
    }
}

@end
