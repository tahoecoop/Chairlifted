//
//  DetailActionTableViewCell.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Like.h"
#import "Post.h"
#import "NetworkRequests.h"


@interface DetailActionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic) Post *post;
@property (nonatomic) Like *like;
@property (nonatomic) UITableView *parentTableView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

- (void)checkIfLiked;


@end
