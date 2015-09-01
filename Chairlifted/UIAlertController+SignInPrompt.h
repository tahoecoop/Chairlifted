//
//  UIAlertController+SignInPrompt.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 9/1/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (SignInPrompt)

+ (UIAlertController *)alertToSignInWithCompletion:(void(^)(BOOL signIn))complete;

@end
