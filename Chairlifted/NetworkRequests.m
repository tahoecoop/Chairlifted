//
//  NetworkRequests.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "NetworkRequests.h"


@implementation NetworkRequests

+ (void)getPostsWithSkipCount:(int)skipCount completion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query orderByDescending:@"hottness"];
    [query includeKey:@"author"];
    query.limit = 30;
    query.skip = skipCount;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            complete(objects);
        }
    }];
}


+ (void)getPostComments:(Post *)post withCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Comment query];
    [query whereKey:@"post" equalTo:post];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}

+ (void)getLikes:(Post *)post withCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Like query];
    [query whereKey:@"post" equalTo:post];
    [query includeKey:@"liker"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}


+ (void)checkForLike:(Post *)post withCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Like query];
    [query whereKey:@"post" equalTo:post];
    [query whereKey:@"liker" equalTo:[User currentUser]];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}

- (void)getWeather
{

}

- (void)getResorts
{

}





@end
