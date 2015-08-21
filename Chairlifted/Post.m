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
@dynamic createdAt;
@dynamic likeCount;
@dynamic commentCount;
@dynamic hottness;
@dynamic postTopic;
@dynamic group;
@dynamic isPrivate;


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
    float likesScore = 0;
    float commentsScore = 0;

    if (self.likeCount > 0)
    {
        likesScore = log10f(self.likeCount) + 0.01;
    }

    if (self.commentCount > 0)
    {
        commentsScore = log10f(self.commentCount) + 0.01;
    }

    if (self.createdAt)
    {
        float seconds = [self.createdAt timeIntervalSinceReferenceDate] / 86400;
        self.hottness = likesScore + commentsScore + seconds;
    }
    else
    {
        float seconds = [[NSDate date] timeIntervalSinceReferenceDate] / 86400;
        self.hottness = likesScore + commentsScore + seconds;
    }
}




@end
