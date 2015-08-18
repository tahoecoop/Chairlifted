//
//  Post.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <Parse/PFFile.h>
#import "User.h"

@interface Post : PFObject <PFSubclassing>

@property (nonatomic) User *user;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *title;
@property (nonatomic) PFFile *image;
@property (nonatomic) NSSet *comments;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) int voteCount;

+ (void)load;
+ (NSString *)parseClassName;


@end
