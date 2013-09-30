//
//  StationAnnotationView.m
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "StationAnnotationView.h"

@implementation StationAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canShowCallout = YES;
        self.multipleTouchEnabled = NO;
        self.draggable = NO;

        self.centerOffset = CGPointMake(40, 0);
        self.calloutOffset = CGPointMake(-41, -1);
        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return self;
}

-(void)prepareCustomViewWithTitle:(NSString*)title {
    circleLayer = [CAShapeLayer layer];
    circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 20, 20)].CGPath;
    circleLayer.fillColor = RGBA(90, 140, 169, 1.0).CGColor;
    circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    circleLayer.lineWidth = 1.0f;
    [self.layer addSublayer:circleLayer];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    
    labelBackground = [CAShapeLayer layer];
    labelBackground.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 20, 20) cornerRadius:10].CGPath;
    labelBackground.fillColor = RGBA(90, 140, 169, 0.9).CGColor;
    [self.layer insertSublayer:labelBackground below:circleLayer];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 20), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = blank;
    

}

-(void)animateWithDelay:(CFTimeInterval)delay {

    [label sizeToFit];
    label.center = CGPointMake(label.center.x, 10);
    CGRect originalLabelRect = label.frame;
    label.frame = CGRectMake(24, 0, 0, 20);
    
    [UIView
     animateWithDuration:0.2f
     delay:delay + 0.5f
     options:UIViewAnimationOptionCurveEaseOut
     animations:^{
         label.frame = originalLabelRect;
     }
     completion:nil];
    
    CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnim.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, label.frame.size.width+30, 20) cornerRadius:10].CGPath;
    pathAnim.duration = 0.2f;
    pathAnim.beginTime = CACurrentMediaTime() + 0.5f + delay;
    pathAnim.fillMode  = kCAFillModeForwards;
    pathAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnim.removedOnCompletion = NO;
    [labelBackground addAnimation:pathAnim forKey:nil];
    
}

@end
