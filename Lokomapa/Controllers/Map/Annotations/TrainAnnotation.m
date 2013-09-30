//
//  TrainAnnotation.m
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "TrainAnnotation.h"

@implementation TrainAnnotation

@synthesize coordinate, title;

- (CLLocationCoordinate2D)coordinate;
{
    return self.train.coords.coordinate;
}

- (NSString *)title
{
    return self.train.name;
}

@end
