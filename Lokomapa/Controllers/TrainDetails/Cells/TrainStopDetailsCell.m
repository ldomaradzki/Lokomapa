//
//  TrainStopDetailsCell.m
//  Lokomapa
//
//  Created by ldomaradzki on 04.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "TrainStopDetailsCell.h"
#import "Train.h"

@implementation TrainStopDetailsCell

-(void)prepareCellWithTrainStop:(TrainStop *)trainStop atIndex:(NSIndexPath*)indexPath {
    self.nameLabel.text = trainStop.stopName;
    if (trainStop.arrivalTime) {
        self.arrivalLabel.text = [NSString stringWithFormat:@"%@ (+%@ min)", [trainStop.arrivalTime getHourMinuteString], [trainStop.arrivalDelay stringValue]];
    }
    else {
        self.arrivalLabel.text = @"Departure station";
    }
    
    if (trainStop.departureTime) {
        self.departureLabel.text = [NSString stringWithFormat:@"%@ (+%@ min)", [trainStop.departureTime getHourMinuteString], [trainStop.departureDelay stringValue]];
    }
    else {
        self.departureLabel.text = @"Destination station";
    }
    
    if (indexPath.row == 0 || indexPath.row == 2) {
        self.bottomLineView.backgroundColor = [UIColor whiteColor];
        [self.layer addSublayer:[self dashedLineInsteadOfView:self.bottomLineView]];
    }
    
    if (indexPath.row == 3 || indexPath.row == 1) {
        self.upperLineView.backgroundColor = [UIColor whiteColor];
        [self.layer addSublayer:[self dashedLineInsteadOfView:self.upperLineView]];
    }
}

-(CAShapeLayer*)dashedLineInsteadOfView:(UIView*)view {
    CAShapeLayer *dashedLineLayer = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    
    if (view == self.bottomLineView)
        [linePath moveToPoint:CGPointMake(view.frame.origin.x+1, view.frame.origin.y)];
    else //compensate strange distances
        [linePath moveToPoint:CGPointMake(view.frame.origin.x+1, view.frame.origin.y-2)];
    
    [linePath addLineToPoint:CGPointMake(view.frame.origin.x+1, view.frame.origin.y+26)];
    
    dashedLineLayer.path = linePath.CGPath;
    dashedLineLayer.lineDashPattern = @[@(4), @(4)];
    dashedLineLayer.strokeColor = RGBA(91, 140, 169, 1.0f).CGColor;
    dashedLineLayer.lineWidth = 2.0f;
    
    return dashedLineLayer;
}

@end
