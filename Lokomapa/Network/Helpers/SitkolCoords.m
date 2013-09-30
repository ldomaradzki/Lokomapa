//
//  SitkolCoords.m
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "SitkolCoords.h"

@implementation CLLocation (CLLocation2Sitkol)

-(SitkolCoords *)convertToSitkolCoords {
    NSString *yCoord = [[NSString stringWithFormat:@"%.06f", self.coordinate.latitude] stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *xCoord = [[NSString stringWithFormat:@"%.06f", self.coordinate.longitude] stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [[SitkolCoords alloc] initWithXCoord:xCoord andYCoord:yCoord];
}

@end

@implementation SitkolCoords

- (id)initWithXCoord:(NSString*)xCoord andYCoord:(NSString*)yCoord
{
    self = [super init];
    if (self) {
        self.xCoord = xCoord;
        self.yCoord = yCoord;
    }
    return self;
}

+(SitkolCoords*)getUpperLeftCornerFromRegion:(MKCoordinateRegion)region {
    CLLocationCoordinate2D center = region.center;
    CLLocationCoordinate2D northWestCorner;
    northWestCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    
    return [[[CLLocation alloc] initWithLatitude:northWestCorner.latitude longitude:northWestCorner.longitude] convertToSitkolCoords];
}

+(SitkolCoords*)getBottomRightCornerFromRegion:(MKCoordinateRegion)region {
    CLLocationCoordinate2D center = region.center;
    CLLocationCoordinate2D southEastCorner;
    southEastCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    return [[[CLLocation alloc] initWithLatitude:southEastCorner.latitude longitude:southEastCorner.longitude] convertToSitkolCoords];
}


@end
