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
        self.alpha = 1.0f;
    } completion:nil];
}

-(void)updateZoomLevel:(double)level {
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = [self changeRect:self.frame toWidth:(1-((level - ZOOM_LEVEL_CEILING) / 12)) * self.superview.bounds.size.width];
    } completion:nil];
}

-(void)hide {
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0f;
    } completion:nil];
}

-(CGRect)changeRect:(CGRect)rect toWidth:(CGFloat)width {
    return CGRectMake(0, rect.origin.y, width, rect.size.height);
}


@end
