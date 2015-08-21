//
//  PostTopic.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/20/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>

@interface PostTopic : PFObject <PFSubclassing>

@property (nonatomic) NSString *name;

+ (void)load;
+ (NSString *)parseClassName;

@end
