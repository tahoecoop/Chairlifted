//
//  Post.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "Post.h"

@implementation Post

@dynamic author;
@dynamic text;
@dynamic title;
@dynamic image;
@dynamic comments;
@dynamic createdAt;
@dynamic voteCount;
@dynamic hottness;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"Post";
}

- (void)calculateHottness
{
    float likesScore = 1;
    float commentsScore = 1;

    if (self.voteCount > 0)
    {
        likesScore = log10f(self.voteCount);
    }

    if (self.comments.count > 0)
    {
        commentsScore = roundf(log10f(self.comments.count));
    }

    float seconds = NSTimeIntervalSince1970 / 20000;
    self.hottness = (likesScore * seconds) + (commentsScore * seconds);
}




@end
