//
//  ZoomIndicatorView.m
//  Lokomapa
//
//  Created by ldomaradzki on 21.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "ZoomIndicatorView.h"

@implementation ZoomIndicatorView

-(void)show {
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.6f;
    } completion:nil];
}

-(void)updateZoomLevel:(double)level {
    if (level < 1.0f) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = [self changeRectToWidth:level * self.superview.bounds.size.width];
            self.frame = [self changeRectToHeight:3];
            self.errorLabel.alpha = 0.0f;
            if ([self.backgroundColor isEqual:[UIColor redColor]]) {
                self.backgroundColor = [UIColor greenColor];
            }
        } completion:nil];
    }
    else {
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = [self changeRectToWidth:self.superview.bounds.size.width];
            self.frame = [self changeRectToHeight:13];
            self.backgroundColor = [UIColor redColor];
            self.errorLabel.alpha = 1.0f;
        } completion:nil];
    }
    
}

-(void)hide {
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if ([self.backgroundColor isEqual:[UIColor greenColor]])
            self.alpha = 0.0f;
    } completion:nil];
}

-(CGRect)changeRectToWidth:(CGFloat)width {
    return CGRectMake(0, self.frame.origin.y, width, self.frame.size.height);
}

-(CGRect)changeRectToHeight:(CGFloat)height{
    return CGRectMake(0, self.frame.origin.y, self.frame.size.width, height);
}


@end
