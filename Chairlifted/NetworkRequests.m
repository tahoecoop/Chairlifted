//
//  NetworkRequests.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "NetworkRequests.h"
#import "Post.h"

@implementation NetworkRequests

+ (void)getPostsWithCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query orderByDescending:@"hottness"];
    [query includeKey:@"author"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            complete(objects);
        }
    }];
}



@end
