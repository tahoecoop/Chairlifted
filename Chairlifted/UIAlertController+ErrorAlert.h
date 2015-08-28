//
//  UIAlertController+ErrorAlert.h
//  Chairlifted
//
//  Created by Eric Schofield on 27Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (ErrorAlert)

+ (UIAlertController *)showErrorAlert: (NSError *)error orMessage: (NSString *)message;

@end
