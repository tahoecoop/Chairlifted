//
//  PostDetailViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) Post *post;

@end
