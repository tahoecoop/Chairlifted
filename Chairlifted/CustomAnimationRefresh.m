//
//  CustomAnimationRefresh.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/31/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CustomAnimationRefresh.h"

@implementation CustomAnimationRefresh


- (void)setupRefreshControl:(UIView *)refreshLoadingView with:(UIView *)refreshColorView
{
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.bounds];
    self.refreshColorView = [[UIView alloc] initWithFrame:self.bounds];


    refreshLoadingView.backgroundColor = [UIColor clearColor];
    refreshColorView.backgroundColor = [UIColor blueColor];
    refreshColorView.alpha = 0.30;


    self.rightFlake = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flake1.png"]];
    self.leftFlake = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flake1.png"]];
    [refreshLoadingView addSubview:self.leftFlake];
    [refreshLoadingView addSubview:self.rightFlake];

    refreshLoadingView.clipsToBounds = YES;
    self.tintColor = [UIColor clearColor];
    [self addSubview:refreshColorView];
    [self addSubview:refreshLoadingView];

    self.isFlakesOverlap = NO;
    self.isAnimating = NO;

    [self addTarget:self action:@selector(refresh:withCompletion:) forControlEvents:UIControlEventValueChanged];
}


- (void)refresh:(id)sender withCompletion:(void(^)(BOOL finished))complete
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       complete(YES);
//                       self.skipCount = 30;
//                       [NetworkRequests getPostsWithSkipCount:0 andGroup:nil andIsPrivate:NO completion:^(NSArray *array)
//                        {
//                            self.posts = [NSMutableArray arrayWithArray:array];
//                            [self.refreshControl endRefreshing];
//                        }];
                   });
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect refreshBounds = self.bounds;
    CGFloat pullDistance = MAX(0.0, -self.frame.origin.y);
    CGFloat midX = [[UIScreen mainScreen]bounds].size.width / 2.0;

    CGFloat rightFlakeHeight = self.rightFlake.bounds.size.height;
    CGFloat rightFlakeHeightHalf = rightFlakeHeight / 2.0;
    CGFloat rightFlakeWidth = self.rightFlake.bounds.size.width;
    CGFloat rightFlakeWidthHalf = rightFlakeWidth / 2.0;
    CGFloat leftFlakeHeight = self.leftFlake.bounds.size.height;
    CGFloat leftFlakeHeightHalf = leftFlakeHeight / 2.0;
    CGFloat leftFlakeWidth = self.leftFlake.bounds.size.width;
    CGFloat leftFlakeWidthHalf = leftFlakeWidth / 2.0;

    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    CGFloat rightFlakeY = pullDistance / 2.0 - rightFlakeHeightHalf;
    CGFloat leftFlakeY = pullDistance / 2.0 - leftFlakeHeightHalf;
    CGFloat rightFlakeX = (midX + rightFlakeWidthHalf) - (rightFlakeWidth * pullRatio);
    CGFloat leftFlakeX = (midX - leftFlakeWidth - leftFlakeWidthHalf) + (leftFlakeWidth * pullRatio);

    if (fabs(rightFlakeX - leftFlakeX) < 1.0)
    {
        self.isFlakesOverlap = YES;
    }

    if (self.isFlakesOverlap || self.isRefreshing)
    {
        rightFlakeX = midX - rightFlakeWidthHalf;
        leftFlakeX = midX - leftFlakeWidthHalf;
    }

    CGRect rightFlakeFrame = self.rightFlake.frame;
    rightFlakeFrame.origin.x = rightFlakeX;
    rightFlakeFrame.origin.y = rightFlakeY;

    CGRect leftFlakeFrame = self.leftFlake.frame;
    leftFlakeFrame.origin.x= leftFlakeX;
    leftFlakeFrame.origin.y = leftFlakeY;

    self.rightFlake.frame = rightFlakeFrame;
    self.leftFlake.frame = leftFlakeFrame;

    refreshBounds.size.height = pullDistance;
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;

    if (self.isRefreshing && !self.isAnimating)
    {
        [self animateRefreshView];
    }
}


- (void)animateRefreshView
{
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    self.isAnimating = YES;

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.leftFlake setTransform:CGAffineTransformRotate(self.leftFlake.transform, M_PI_2)];
                         [self.rightFlake setTransform:CGAffineTransformRotate(self.rightFlake.transform, -M_PI_2)];
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished)
     {
         if (self.isRefreshing)
         {
             [self animateRefreshView];
         }
         else
         {
             [self resetAnimation];
             [self reloadTheTableViewWithCompletion:^(BOOL finished)
             {
                 
             }];
//             [self.tableView reloadData];

         }
     }];
}


- (void)resetAnimation
{
    self.isAnimating = NO;
    self.isFlakesOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor blueColor];
}


- (void)reloadTheTableViewWithCompletion:(void(^)(BOOL finished))complete
{
    complete(YES);
}


@end
