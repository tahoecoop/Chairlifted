//
//  UIAlertController+SignInPrompt.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 9/1/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "UIAlertController+SignInPrompt.h"

@implementation UIAlertController (SignInPrompt)

+ (UIAlertController *)alertToSignInWithCompletion:(void(^)(BOOL signIn))complete
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Account required to use this feature." message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *signIn = [UIAlertAction actionWithTitle:@"Sign In" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                       {
                                           complete(YES);
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:^
                                  {
                                      complete(NO);
                                  }];
                             }];
    
    [alert addAction:signIn];
    [alert addAction:cancel];

    return alert;
}


@end
