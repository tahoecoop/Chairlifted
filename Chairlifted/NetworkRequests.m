//
//  NetworkRequests.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "NetworkRequests.h"


@implementation NetworkRequests

#pragma mark - Post methods


+ (void)getPostsWithSkipCount:(int)skipCount fromGroup:(Group *)group sortedBy:(SortSelection)sortSelection andIsPrivate:(BOOL)isPrivate completion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:isPrivate]];
    [query includeKey:@"author"];
    query.limit = 30;
    query.skip = skipCount;
    if (group)
    {
        [query whereKey:@"group" equalTo:group];
    }

    if (sortSelection == SortSelectionHottest)
    {
        [query orderByDescending:@"hottness"];
    }
    else if (sortSelection == SortSelectionNewest)
    {
        [query orderByDescending:@"createdAt"];
    }
    else if (sortSelection == SortSelectionMostLikes)
    {
        [query orderByDescending:@"likeCount"];
    }
    else if (sortSelection == SortSelectionMostComments)
    {
        [query orderByDescending:@"commentCount"];
    }


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (error)
        {
//            UIAlertController *alert = [UIAlertController showErrorAlert:error orMessage:nil];
        }
        else
        {
            complete(objects);
        }
    }];
}



+ (void)getPostsWithSkipCount:(int)skipCount andUser:(User *)user andShowsPrivate:(BOOL)showsPrivate completion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query whereKey:@"author" equalTo:user];

    if (!showsPrivate)
    {
        [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    }

    [query orderByDescending:@"createdAt"];
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


+ (void)getPostsFromSearch:(NSString *)searchTerm WithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query orderByAscending:@"title"];
    [query includeKey:@"author"];
    [query whereKey:@"lowercaseTitle" containsString:searchTerm];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:@"createdAt"];
    query.skip = skipCount;
    query.limit = 30;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}


+ (void)getPostsWithTopic:(NSString *)topic WithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query orderByDescending:@"hottness"];
    [query includeKey:@"author"];
    [query whereKey:@"postTopic" equalTo:topic];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:@"hottness"];
    query.skip = skipCount;
    query.limit = 30;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}


+ (void)getPostsWithSkipCount:(int)skipCount andResort:(Resort *)resort andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Post query];
    [query whereKey:@"resort" equalTo:resort];
    [query whereKey:@"isPrivate" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:@"hottness"];
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



#pragma mark - comment methods

+ (void)getPostComments:(Post *)post withSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Comment query];
    [query whereKey:@"post" equalTo:post];
    [query includeKey:@"author"];
    [query includeKey:@"group"];
    [query orderByAscending:@"createdAt"];
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

#pragma mark - like methods


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

#pragma mark - topic methods

+ (void)getTopicsWithCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [PostTopic query];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}

#pragma mark - group methods

+ (void)getMyGroupsWithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *queryJoined = [JoinGroup query];
    [queryJoined whereKey:@"user" equalTo:[User currentUser]];
    [queryJoined whereKey:@"status" equalTo:@"joined"];

    PFQuery *queryAdmin = [JoinGroup query];
    [queryAdmin whereKey:@"user" equalTo:[User currentUser]];
    [queryAdmin whereKey:@"status" equalTo:@"admin"];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryJoined, queryAdmin]];
    [query includeKey:@"group"];

    [query orderByDescending:@"mostRecentPost"];
    query.skip = skipCount;
    query.limit = 30;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}


+ (void)getJoinGroupIfAlreadyJoinedWithGroup:(Group *)group andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [JoinGroup query];
    [query whereKey:@"user" equalTo:[User currentUser]];
    [query whereKey:@"group" equalTo:group];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}


+ (void)getAllGroupsWithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Group query];
    [query orderByDescending:@"memberQuantity"];
    query.skip = skipCount;
    query.limit = 30;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}


+ (void)getGroupsFromSearch:(NSString *)searchTerm WithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Group query];
    [query orderByAscending:@"lowercaseName"];
    [query whereKey:@"lowercaseName" containsString:searchTerm];
    query.skip = skipCount;
    query.limit = 30;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}

+ (void)checkIfGroupNameExists:(NSString *)name andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Group query];
    [query orderByAscending:@"name"];
    [query whereKey:@"name" equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}



#pragma mark - Get Users

+(void)getPendingUsersInGroup:(Group *)group andSkipCount: (int)skipCount withCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [JoinGroup query];
    [query whereKey:@"group" equalTo:group];
    [query whereKey:@"status" equalTo:@"pending"];
    [query orderByAscending:@"createdAt"];
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

+(void)getJoinedUsersInGroup:(Group *)group andSkipCount: (int)skipCount withCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *queryJoined = [JoinGroup query];
    [queryJoined whereKey:@"status" equalTo:@"joined"];
    [queryJoined whereKey:@"group" equalTo:group];

    PFQuery *queryAdmin = [JoinGroup query];
    [queryAdmin whereKey:@"status" equalTo:@"admin"];
    [queryAdmin whereKey:@"group" equalTo:group];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryJoined, queryAdmin]];
    [query orderByAscending:@"userUsername"];
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


+ (void)getDisplayNamesWithDisplayName: (NSString *)name Completion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [User query];
    [query whereKey:@"displayName" equalTo:name];

    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         if (!error)
         {
             complete(array);
         }
     }];
}


//+ (void)getNewUser



#pragma mark - get Resorts

+ (void)getResortsWithState:(NSString *)state andCompletion:(void(^)(NSArray *array))complete
{
    PFQuery *query = [Resort query];
    [query orderByAscending:@"name"];
    [query whereKey:@"state" equalTo:state];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             complete(objects);
         }
     }];
}



#pragma mark - Get weather

+ (void)getWeatherFromLatitude:(double)latitude andLongitude:(double)longitude andCompletion:(void(^)(NSDictionary *dictionary))complete
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.forecast.io/forecast/20788a00b48f1134a3caba1ed068b963/%f,%f", latitude, longitude]];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
          complete(dict[@"currently"]);
      }] resume];
}




@end
