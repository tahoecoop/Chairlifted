//
//  Like.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import "Post.h"
#import "User.h"

@interface Like : PFObject <PFSubclassing>

@property (nonatomic) Post *post;
@property (nonatomic) User *liker;

+ (void)load;
+ (NSString *)parseClassName;

@end
