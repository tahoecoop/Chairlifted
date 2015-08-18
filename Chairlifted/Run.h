//
//  Run.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <Parse/PFFile.h>

@interface Run : PFObject <PFSubclassing>

@property (nonatomic) float *relativeAltitude;
@property (nonatomic) float *speed;
@property (nonatomic) float *timeOfRun;
@property (nonatomic) NSDate *createdAt;

+ (void)load;
+ (NSString *)parseClassName;


@end
