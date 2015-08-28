//
//  TopicsFeedViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/27/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostTopic.h"
#import "Resort.h"

@interface TopicsFeedViewController : UIViewController

@property (nonatomic) NSString *postTopic;
@property (nonatomic) Resort *resort;

@end
