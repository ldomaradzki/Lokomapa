//
//  Station.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "Station.h"
#import "SitkolAPIClient.h"

static NSString * const SitkolAPIQueryGETURLString = @"bin/query.exe/pny";

@interface SitkolCoords : NSObject

@property (nonatomic, copy) NSString *xCoord, *yCoord;
- (id)initWithXCoord:(NSString*)xCoord andYCoord:(NSString*)yCoord;
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

@end

@implementation CLLocation (CLLocation2Sitkol)

// lat - y
// lon - x

-(SitkolCoords *)convertToSitkolCoords {
    NSString *yCoord = [[NSString stringWithFormat:@"%.06f", self.coordinate.latitude] stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *xCoord = [[NSString stringWithFormat:@"%.06f", self.coordinate.longitude] stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [[SitkolCoords alloc] initWithXCoord:xCoord andYCoord:yCoord];
}

@end

@implementation Station

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.externalId = @([attributes[@"extId"] integerValue]);
    self.name = attributes[@"name"];
    self.planId = @([attributes[@"planId"] integerValue]);
    self.prodClass = @([attributes[@"prodclass"] integerValue]);
    self.puic = @([attributes[@"puic"] integerValue]);
    self.stopWeight = @([attributes[@"stopweight"] integerValue]);
    self.urlName = attributes[@"urlname"];
    self.coords = [[CLLocation alloc]
                   initWithLatitude:([attributes[@"y"] doubleValue] / 1000000.0f)
                   longitude:([attributes[@"x"] doubleValue] / 1000000.0f)];
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.externalId];
}

#pragma mark - GET methods

+(NSURLSessionDataTask *)stationsInRegion:(MKCoordinateRegion)region withBlock:(void (^)(NSArray *, NSError *))block {
    SitkolCoords *bottomRight = [Station getBottomRightCornerFromRegion:region];
    SitkolCoords *upperLeft = [Station getUpperLeftCornerFromRegion:region];
    
    NSDictionary *parameters =
  @{
    @"tpl": @"stop2json",
    @"look_stopclass": @"8",
    @"look_maxdist": @"2088642",
    @"look_nv": @"get_stopweight|yes",
    @"look_maxno": @"150",
    @"performLocating": @"2",
    
    @"look_maxx": bottomRight.xCoord,
    @"look_maxy": upperLeft.yCoord,
    @"look_minx": upperLeft.xCoord,
    @"look_miny": bottomRight.yCoord
    };

    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIQueryGETURLString
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                NSMutableArray *stationsFromResponse = JSON[@"stops"];
                NSMutableArray *stations = [NSMutableArray arrayWithCapacity:stationsFromResponse.count];
                for (NSDictionary *attributes in stationsFromResponse) {
                    Station *station = [[Station alloc] initWithAttributes:attributes];
                    [stations addObject:station];
                }
                
                if (block) {
                    block([NSArray arrayWithArray:stations], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([NSArray array], error);
                }
            }];
}

#pragma mark - Helpers

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
