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

@interface NetworkRequests : NSObject

+ (void)getPostsWithSkipCount:(int)skipCount completion:(void(^)(NSArray *array))complete;
+ (void)getPostComments:(Post *)post withCompletion:(void(^)(NSArray *array))complete;
+ (void)getLikes:(Post *)post withCompletion:(void(^)(NSArray *array))complete;
+ (void)checkForLike:(Post *)post withCompletion:(void(^)(NSArray *array))complete;


@end
