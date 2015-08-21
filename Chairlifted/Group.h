//
//  Group.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/20/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>

@interface Group : PFObject <PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *isPrivate;
@property (nonatomic) NSDate *mostRecentPost;
@property (nonatomic) int memberQuantity;
@property (nonatomic) NSString *purpose;
@property (nonatomic) PFFile *image;


+ (void)load;
+ (NSString *)parseClassName;

@end
