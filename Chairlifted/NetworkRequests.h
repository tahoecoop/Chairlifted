//
//  NetworkRequests.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkRequests : NSObject

+ (void)getPostsWithCompletion:(void(^)(NSArray *array))complete;

@end
