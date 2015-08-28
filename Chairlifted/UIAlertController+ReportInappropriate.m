//
//  UIAlertController+ReportInappropriate.m
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import "UIAlertController+ReportInappropriate.h"

@implementation UIAlertController (ReportInappropriate)

@dynamic delegate;

+ (UIAlertController *)alertForReportInappropriateWithCompletion:(void(^)(BOOL sendReport))complete
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:@"Report Inappropriate" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
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
    
    [alert addAction:reportUserAction];
    [alert addAction:cancel];
    
    return alert;
}


@end
