//
//  UIAlertController+ErrorAlert.m
//  Chairlifted
//
//  Created by Eric Schofield on 27Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import "UIAlertController+ErrorAlert.h"

@implementation UIAlertController (ErrorAlert)


+ (UIAlertController *)showErrorAlert: (NSError *)error orMessage: (NSString *)message
{
    UIAlertController *alert;
    if (message)
    {
        alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    }
    else
    {
        alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    UIAlertAction *errorAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
   {
       [alert dismissViewControllerAnimated:YES completion:nil];
   }];

    [alert addAction:errorAction];
    
    return alert;
}


@end
