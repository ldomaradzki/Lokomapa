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

@implementation Station

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.externalId = @([attributes[@"extId"] integerValue]);
    self.name = [attributes[@"name"] cleanWhitespace];
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

#pragma mark - API methods

+(NSURLSessionDataTask *)stationsInRegion:(MKCoordinateRegion)region withBlock:(void (^)(NSArray *, NSError *))block {
    SitkolCoords *bottomRight = [SitkolCoords getBottomRightCornerFromRegion:region];
    SitkolCoords *upperLeft = [SitkolCoords getUpperLeftCornerFromRegion:region];
    
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

                if (block) {
                    block([Station parseStationData:JSON], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
            #if NETWORK_DEBUG
                if (block) {
                    block([Station parseStationData:[NSJSONSerialization JSONObjectWithResourceJSONFile:@"TestStationResponse"]], nil);
                }
            #else
                if (block) {
                    block([NSArray array], error);
                }
            #endif
            }];
}

+(NSArray*)parseStationData:(id)JSON {
    NSMutableArray *stationsFromResponse = JSON[@"stops"];
    NSMutableArray *stations = [NSMutableArray arrayWithCapacity:stationsFromResponse.count];
    for (NSDictionary *attributes in stationsFromResponse) {
        Station *station = [[Station alloc] initWithAttributes:attributes];
        [stations addObject:station];
    }
    
    return [NSArray arrayWithArray:stations];
}

@end
