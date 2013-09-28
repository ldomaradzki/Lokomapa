//
//  Station.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "Station.h"
#import "SitkolAPIClient.h"

static NSString * const SitkolAPIStationsGETUrl = @"bin/query.exe/pny";

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
    self.xCoord = @([attributes[@"x"] integerValue]);
    self.yCoord = @([attributes[@"y"] integerValue]);
    
    return self;
}

+(NSURLSessionDataTask *)stationsWithBlock:(void (^)(NSArray *, NSError *))block {
    
    NSDictionary *parameters =
  @{
    @"tpl": @"stop2json",
    @"look_stopclass": @"8",
    @"look_maxdist": @"2088642",
    @"look_nv": @"get_stopweight|yes",
    @"look_maxno": @"150",
    @"performLocating": @"2",
    
    @"look_minx": @"18508902",
    @"look_miny": @"54432830",
    @"look_maxx": @"18611899",
    @"look_maxy": @"54482724",
    };

    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIStationsGETUrl
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

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.externalId];
}

@end
