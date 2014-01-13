//
//  Schedule.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "Schedule.h"
#import "SitkolAPIClient.h"

static NSString * const SitkolAPIStationGETURLString = @"bin/stboard.exe/pn";

@implementation Journey

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH:mm dd.MM.yy"];
    
    self.destinationStation = [attributes[@"st"] stringByDecodingXMLEntities];
    self.delay = @""; // ??
    self.journeyId = attributes[@"id"];
    self.train = [attributes[@"pr"] cleanWhitespace];
    self.arrivalTime = [hourFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", attributes[@"ti"], attributes[@"da"]]];
    self.trainId = [[attributes[@"tinfo"]
                     stringByReplacingOccurrencesOfString:@"http://rozklad.sitkol.pl/bin/traininfo.exe/pn/" withString:@""] componentsSeparatedByString:@"?"][0];
    
    return self;
}

- (NSString*)getDelayString {
    if (self.delay) {
        if ([self.delay isEqualToString:@"OK"]) {
            return @"";
        }
        else {
            return [NSString stringWithFormat:@"%@", self.delay];
        }
    }
    return @"";
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

#pragma mark - API methods

+ (NSURLSessionDataTask*)stationBetterSchedule:(NSNumber*)stationId withBlock:(void (^)(Schedule *schedule, NSError *error))block {
    
    if (!stationId) return nil;
    
    NSDictionary *parameters =
    @{
      @"L": @"vs_stb",
      @"boardType": @"dep",
      @"selectDate": @"today",
      @"time": @"now",
      @"productsFilter": @"1111111111",
      @"additionalTime": @"0",
      @"maxJourneys": @"30",
      @"outputMode": @"undefined",
      @"start": @"yes",
      @"monitor": @"1",
      @"requestType": @"0",
      
      @"input": [stationId stringValue]
      };
    
    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIStationGETURLString
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                
                if (block) {
                    block([Schedule parseBetterScheduleData:JSON], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
#if NETWORK_DEBUG
                if (block) {
                    block([Schedule parseScheduleData:[NSJSONSerialization JSONObjectWithResourceJSONFile:@"TestScheduleResponse"]], nil);
                }
#else
                if (block) {
                    block([Schedule new], error);
                }
#endif
            }];
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
      @"maxJourneys": @"30",
      @"start": @"1343079701735",
      @"ajax": @"yes",
      
      @"input": [stationId stringValue]
      };
    
    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIStationGETURLString
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                
                if (block) {
                    block([Schedule parseScheduleData:JSON], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
            #if NETWORK_DEBUG
                if (block) {
                    block([Schedule parseScheduleData:[NSJSONSerialization JSONObjectWithResourceJSONFile:@"TestScheduleResponse"]], nil);
                }
            #else
                if (block) {
                    block([Schedule new], error);
                }
            #endif
            }];
}

+(Schedule*)parseScheduleData:(id)JSON {
    NSDictionary *attributesFromResponse = JSON[@"stBoard"];
    Schedule *schedule = [[Schedule alloc] initWithAttributes:attributesFromResponse];
    
    return schedule;
}

+(Schedule*)parseBetterScheduleData:(id)JSON {
    NSDictionary *attributesFromResponse = JSON;
    Schedule *schedule = [[Schedule alloc] initWithAttributes:attributesFromResponse];
    
    return schedule;
    
}

@end
