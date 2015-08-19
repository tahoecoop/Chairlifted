//
//  UIAlertController+UIImagePicker.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "UIAlertController+UIImagePicker.h"

@implementation UIAlertController (UIImagePicker)

+ (UIAlertController *)prepareForImagePicker:(UIViewController *)superSelf
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.delegate = superSelf;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [superSelf presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose from camera roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
      {
          UIImagePickerController *picker = [UIImagePickerController new];
          picker.delegate = superSelf;
          picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
          [superSelf presentViewController:picker animated:YES completion:nil];
      }];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
      {
          [superSelf dismissViewControllerAnimated:YES completion:nil];
      }];

    [alert addAction:takePhoto];
    [alert addAction:choosePhoto];
    [alert addAction:dismiss];
    return alert;
}


@end
