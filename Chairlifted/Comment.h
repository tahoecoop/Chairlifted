//
//  Comment.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <Parse/PFFile.h>
#import "User.h"
#import "Post.h"

@interface Comment : PFObject <PFSubclassing>

@property (nonatomic) User *author;
@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *createdAt;
@property (nonatomic) Post *post;

+ (void)load;
+ (NSString *)parseClassName;



@end
