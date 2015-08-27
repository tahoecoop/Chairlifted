//
//  UIAlertController+ReportInappropriate.m
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import "UIAlertController+ReportInappropriate.h"

@implementation UIAlertController (ReportInappropriate)

+ (UIAlertController *)alertForReportInappropriate
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *reportUserAction = [UIAlertAction actionWithTitle:@"Report Inappropriate" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
    {
        // Send a stock email to ourselves reporting the user/post/group
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:reportUserAction];
    [alert addAction:cancel];
    
    return alert;
}


@end
