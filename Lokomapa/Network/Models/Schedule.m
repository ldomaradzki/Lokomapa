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
    
    self.destinationStation = [attributes[@"dest"] stringByDecodingXMLEntities];
    self.delay = [[attributes[@"delay"] stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"ok. " withString:@""];
    self.journeyId = attributes[@"id"];
    self.train = [attributes[@"product"] cleanWhitespace];
    self.arrivalTime = [attributes[@"time"] getHourMinuteDate];
    
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
            GET:SitkolAPIStationGETURLString
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                
                if (block) {
                    block([Schedule parseScheduleData:JSON], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([Schedule new], error);
                }
            }];
}

+(Schedule*)parseScheduleData:(id)JSON {
    NSDictionary *attributesFromResponse = JSON[@"stBoard"];
    Schedule *schedule = [[Schedule alloc] initWithAttributes:attributesFromResponse];
    
    return schedule;
}

@end
