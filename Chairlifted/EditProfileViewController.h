//
//  EditProfileViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resort.h"

@interface EditProfileViewController : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *resortNameLabel;
@property (nonatomic) Resort *selectedResort;


@end
