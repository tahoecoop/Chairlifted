//
//  EditProfileViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resort.h"

@protocol updatedResortDelegate;

@interface EditProfileViewController : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (nonatomic) Resort *selectedResort;
@property (nonatomic) id <updatedResortDelegate> delegate;



@end

@protocol updatedResortDelegate <NSObject>

- (void)didUpdateResort;

@end