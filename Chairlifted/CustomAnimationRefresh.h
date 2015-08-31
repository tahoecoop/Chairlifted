//
//  CustomAnimationRefresh.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/31/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAnimationRefresh : UIRefreshControl

@property (nonatomic) BOOL isFlakesOverlap;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) UIImageView *rightFlake;
@property (nonatomic, strong) UIImageView *leftFlake;
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;


@end
