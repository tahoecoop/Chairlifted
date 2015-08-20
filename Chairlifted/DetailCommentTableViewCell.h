//
//  DetailCommentTableViewCell.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTimeLabel;

@end
