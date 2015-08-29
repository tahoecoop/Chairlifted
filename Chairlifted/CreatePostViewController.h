//
//  CreatePostViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Resort.h"

@interface CreatePostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic) Group *group;
@property (nonatomic) Resort *selectedResort;

@end
