//
//  UIImageView+SpinningFigure.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/25/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "UIImageView+SpinningFigure.h"

@implementation UIImageView (SpinningFigure)


- (void)rotateLayerInfinite
{
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.toValue = [NSNumber numberWithFloat:0];
    rotation.duration = 0.9f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [self.layer removeAllAnimations];
    [self.layer addAnimation:rotation forKey:@"Spin"];
}



@end
