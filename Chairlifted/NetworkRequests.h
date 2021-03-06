//
//  NetworkRequests.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "Comment.h"
#import "Like.h"
#import "PostTopic.h"
#import "JoinGroup.h"
#import "Resort.h"
#import "UIAlertController+ErrorAlert.h"

typedef NS_ENUM(NSInteger, SortSelection)
{
    SortSelectionHottest = 0,
    SortSelectionNewest,
    SortSelectionMostLikes,
    SortSelectionMostComments
};


@interface NetworkRequests : NSObject

+ (void)getPostsWithSkipCount:(int)skipCount fromGroup:(Group *)group sortedBy:(SortSelection)sortSelection andIsPrivate:(BOOL)isPrivate completion:(void(^)(NSArray *array))complete;
+(void)getDisplayNamesWithDisplayName: (NSString *)name Completion:(void(^)(NSArray *array))complete;
+ (void)getPostComments:(Post *)post withSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete;
+ (void)getPostsWithSkipCount:(int)skipCount andUser:(User *)user andShowsPrivate:(BOOL)showsPrivate completion:(void(^)(NSArray *array))complete;
+ (void)getPostsFromSearch:(NSString *)searchTerm WithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete;
+ (void)getPostsWithTopic:(NSString *)topic WithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete;
+ (void)getPostsWithSkipCount:(int)skipCount andResort:(Resort *)resort andCompletion:(void(^)(NSArray *array))complete;

+ (void)getLikes:(Post *)post withCompletion:(void(^)(NSArray *array))complete;
+ (void)checkForLike:(Post *)post withCompletion:(void(^)(NSArray *array))complete;

+ (void)getTopicsWithCompletion:(void(^)(NSArray *array))complete;

+ (void)getMyGroupsWithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete;
+ (void)getJoinGroupIfAlreadyJoinedWithGroup:(Group *)group andCompletion:(void(^)(NSArray *array))complete;
+ (void)getAllGroupsWithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete;
+ (void)getGroupsFromSearch:(NSString *)searchTerm WithSkipCount:(int)skipCount andCompletion:(void(^)(NSArray *array))complete;
+ (void)checkIfGroupNameExists:(NSString *)name andCompletion:(void(^)(NSArray *array))complete;


+(void)getPendingUsersInGroup:(Group *)group andSkipCount: (int)skipCount withCompletion:(void(^)(NSArray *array))complete;
+(void)getJoinedUsersInGroup:(Group *)group andSkipCount: (int)skipCount withCompletion:(void(^)(NSArray *array))complete;

+ (void)getResortsWithState:(NSString *)state andCompletion:(void(^)(NSArray *array))complete;
+ (void)getWeatherFromLatitude:(double)latitude andLongitude:(double)longitude andCompletion:(void(^)(NSDictionary *dictionary))complete;


@property (nonatomic, assign) SortSelection selection;

@end
