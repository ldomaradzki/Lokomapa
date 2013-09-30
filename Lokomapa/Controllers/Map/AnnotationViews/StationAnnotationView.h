//
//  StationAnnotationView.h
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

@interface StationAnnotationView : MKAnnotationView {
    CAShapeLayer *circleLayer;
    UILabel *label;
    CAShapeLayer *labelBackground;
    
}

-(void)prepareCustomViewWithTitle:(NSString*)title;
-(void)animateWithDelay:(CFTimeInterval)delay;

@end
