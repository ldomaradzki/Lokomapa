//
//  ZoomIndicatorView.m
//  Lokomapa
//
//  Created by ldomaradzki on 21.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "ZoomIndicatorView.h"

@implementation ZoomIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)show {
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.6f;
    } completion:nil];
}

-(void)updateZoomLevel:(double)level {
    double percentageLevel = 1 - ((level - ZOOM_LEVEL_CEILING) / 12);
    
    if (percentageLevel < 1.0f) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = [self changeRectToWidth:percentageLevel * self.superview.bounds.size.width];
            self.frame = [self changeRectToHeight:3];
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
        } completion:nil];
    }
    
}

-(void)hide {
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
