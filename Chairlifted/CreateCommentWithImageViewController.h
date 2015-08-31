//
//  CreateCommentWithImageViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface CreateCommentWithImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *postBodyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (nonatomic) Post *post;

@end
