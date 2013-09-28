//
//  Schedule.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "Schedule.h"
#import "SitkolAPIClient.h"

@implementation Journey

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH:mm"];
    
    self.destinationStation = attributes[@"dest"];
    self.delay = attributes[@"delay"];
    self.journeyId = attributes[@"id"];
    self.train = attributes[@"product"];
    self.arrivalTime = [hourFormatter dateFromString:attributes[@"time"]];
    
    return self;
}

@end

@implementation Schedule

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSMutableArray *journeys = [NSMutableArray arrayWithCapacity:[attributes[@"journey"] count]];
    for (NSDictionary *journeyAttributes in attributes[@"journey"]) {
        Journey *journey = [[Journey alloc] initWithAttributes:journeyAttributes];
        [journeys addObject:journey];
    }

    self.name = attributes[@"name"];
    self.journeys = [NSArray arrayWithArray:journeys];
    
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ (journeys count:%d)", self.name, self.journeys.count];
}

+ (NSURLSessionDataTask*)stationSchedule:(NSNumber*)stationId withBlock:(void (^)(Schedule *schedule, NSError *error))block {
    
    NSDictionary *parameters =
    @{
      @"boardType": @"dep",
      @"disableEquivs": @"yes",
      @"ignoreMasts": @"yes",
      @"selectDate": @"today",
      @"time": @"now",
      @"productsFilter": @"1111111111",
      @"maxJourneys": @"20",
      @"start": @"1343079701735",
      @"ajax": @"yes",
      
      @"input": [stationId stringValue]
      };
    
    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIStationGETUrl
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                NSDictionary *attributesFromResponse = JSON[@"stBoard"];
                Schedule *schedule = [[Schedule alloc] initWithAttributes:attributesFromResponse];
                if (block) {
                    block(schedule, nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([Schedule new], error);
                }
            }];
}

@end
