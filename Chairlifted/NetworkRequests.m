//
//  NetworkRequests.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "NetworkRequests.h"


@implementation NetworkRequests

+ (void)getPostsWithSkipCount:(int)skipCount andGroup:(Group *)group andIsPrivate:(BOOL)isPrivate completion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:isPrivate]];
    [query orderByDescending:@"hottness"];
    [query includeKey:@"author"];
    query.limit = 30;
    query.skip = skipCount;
    if (group)
    {
        [query whereKey:@"group" equalTo:group];
    }
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
    [query includeKey:@"author"];
    [query includeKey:@"group"];
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

+ (void)getTopicsWithCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [PostTopic query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}

+ (void)getMyGroupsWithCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [JoinGroup query];
    [query whereKey:@"user" equalTo:[User currentUser]];
    [query includeKey:@"group"];
    [query orderByDescending:@"mostRecentPost"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}

+ (void)getAllGroupsWithCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Group query];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}





@end
