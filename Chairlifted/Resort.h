//
//  Resort.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <Parse/PFFile.h>

@interface Resort : PFObject <PFSubclassing>

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *country;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;



+ (void)load;
+ (NSString *)parseClassName;


@end
