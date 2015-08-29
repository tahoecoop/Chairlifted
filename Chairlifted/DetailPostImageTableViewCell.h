//
//  DetailPostImageTableViewCell.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPostImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *postText;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;


@end
