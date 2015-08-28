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
#import "PostTopic.h"
#import "Group.h"

@interface Post : PFObject <PFSubclassing>

@property (nonatomic) User *author;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *title;
@property (nonatomic) PFFile *image;
@property (nonatomic) PFFile *imageThumbnail;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) int likeCount;
@property (nonatomic) float hottness;
@property (nonatomic) int commentCount;
@property (nonatomic) NSString *postTopic;
@property (nonatomic) Group *group;
@property (nonatomic) NSNumber *isPrivate;



+ (void)load;
+ (NSString *)parseClassName;
- (void)calculateHottness;


@end
