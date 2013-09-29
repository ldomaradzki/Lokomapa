//
//  StationAnnotation.m
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "StationAnnotation.h"

@implementation StationAnnotation

@synthesize coordinate, title;

- (CLLocationCoordinate2D)coordinate;
{
    return self.station.coords.coordinate;
}

- (NSString *)title
{
    return self.station.name;
}

@end
