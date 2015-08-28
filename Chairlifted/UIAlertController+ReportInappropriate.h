//
//  UIAlertController+ReportInappropriate.h
//  Chairlifted
//
//  Created by Eric Schofield on 26Aug//2015.
//  Copyright © 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendReportInappropriateEmailDelegate;

@interface UIAlertController (ReportInappropriate)

+ (UIAlertController *)alertForReportInappropriateWithCompletion:(void(^)(BOOL sendReport))complete;

@property (nonatomic, weak) id<SendReportInappropriateEmailDelegate>delegate;

@end

@protocol SendReportInappropriateEmailDelegate <NSObject>

-(void)didSelectReportInappropriate;

@end
