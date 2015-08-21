//
//  CreateGroupViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/21/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol doneSavingDelegate;

@interface CreateGroupViewController : UIViewController

@property (nonatomic, weak) IBOutlet id <doneSavingDelegate> delegate;

@end

@protocol doneSavingDelegate <NSObject>

- (void)didFinishSaving;

@end