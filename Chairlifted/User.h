//
//  User.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <Parse/PFFile.h>

@interface User : PFUser <PFSubclassing>

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *email;
@property (nonatomic) NSSet *friends;
@property (nonatomic) NSSet *runs;
@property (nonatomic) NSSet *posts;
@property (nonatomic) NSSet *favoriteResorts;
@property (nonatomic) PFFile *profileImage;

+ (void)load;


@end
