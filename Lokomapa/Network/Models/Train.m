//
//  Train.m
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "Train.h"
#import "SitkolAPIClient.h"

static NSString * const SitkolAPIQueryGETURLString = @"bin/query.exe/pny";

@implementation NSString (prefixUtil)

-(NSString*)addPrefix:(NSString*)prefix {
    return [NSString stringWithFormat:@"%@%@", prefix, self];
}

@end

@implementation TrainStop

-(instancetype)initWithPrefix:(NSString *)prefix andAttributes:(NSDictionary*)attributes {
    self = [super init];
    if (self) {
        self.stopName = attributes[[@"stopname" addPrefix:prefix]];
        
        self.departureTime = [attributes[[@"dep" addPrefix:prefix]] getHourMinuteDate];
        self.arrivalTime = [attributes[[@"arr" addPrefix:prefix]] getHourMinuteDate];
        
        self.departureDelay = @([attributes[[@"dep_d" addPrefix:prefix]] intValue]);
        self.arrivalDelay = @([attributes[[@"arr_d" addPrefix:prefix]] intValue]);
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@", self.stopName];
}

@end

@implementation Train

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stopName = [attributes[@"lstopname"] cleanWhitespace];
    self.name = [attributes[@"name"] cleanWhitespace];
    self.trainId = attributes[@"trainid"];
    self.delay = @([attributes[@"delay"] integerValue]);
    self.direction = @([attributes[@"direction"] integerValue]);
    self.passedPercent = @([attributes[@"passproc"] integerValue]);
    self.prodClass = @([attributes[@"prodclass"] integerValue]);
    self.coords = [[CLLocation alloc]
                   initWithLatitude:([attributes[@"y"] doubleValue] / 1000000.0f)
                   longitude:([attributes[@"x"] doubleValue] / 1000000.0f)];

    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ -> %@", self.name, self.stopName];
}

-(void)updateTrainDetailsWithAttributes:(NSDictionary*)attributes {
    self.firstStop = [[TrainStop alloc] initWithPrefix:@"f" andAttributes:attributes];
    self.nowStop = [[TrainStop alloc] initWithPrefix:@"n" andAttributes:attributes];
    self.passedStop = [[TrainStop alloc] initWithPrefix:@"p" andAttributes:attributes];
    self.lastStop = [[TrainStop alloc] initWithPrefix:@"l" andAttributes:attributes];
}

-(TrainStop *)sortedTrainStopForPlace:(int)number {
    return @[self.firstStop, self.passedStop, self.nowStop, self.lastStop][number];
}

#pragma mark - API methods

+(NSURLSessionDataTask *)trainsInRegion:(MKCoordinateRegion)region withBlock:(void (^)(NSArray *, NSError *))block {
    SitkolCoords *bottomRight = [SitkolCoords getBottomRightCornerFromRegion:region];
    SitkolCoords *upperLeft = [SitkolCoords getUpperLeftCornerFromRegion:region];
    
    NSDictionary *parameters =
    @{
      @"tpl": @"trains2json",
      @"look_productclass": @"127",
      @"look_json": @"yes",
      @"performLocating": @"1",
      
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
                    block([Train parseTrainData:JSON], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
            #if NETWORK_DEBUG
                if (block) {
                    block([Train parseTrainData:[NSJSONSerialization JSONObjectWithResourceJSONFile:@"TestTrainResponse"]], nil);
                }
            #else
                if (block) {
                    block([NSArray array], error);
                }
            #endif
            }];
}

+(NSArray*)parseTrainData:(id)JSON {
    NSMutableArray *trainsFromResponse = JSON[@"look"][@"trains"];
    NSMutableArray *trains = [NSMutableArray arrayWithCapacity:trainsFromResponse.count];
    for (NSDictionary *attributes in trainsFromResponse) {
        Train *train = [[Train alloc] initWithAttributes:attributes];
        [trains addObject:train];
    }
    
    return [NSArray arrayWithArray:trains];
}

-(NSURLSessionDataTask *)trainDetailsWithBlock:(void (^)(NSError *))block {
    NSDictionary *parameters =
    @{
      @"tpl": @"singletrain2json",
      @"look_nv": @"get_rtstoptimes|yes",
      @"performLocating": @"8",
      
      @"look_trainid": self.trainId
      };
    
    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIQueryGETURLString
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                
                [Train parseTrainDetailsData:JSON forObject:self];
                
                if (block) {
                    block(nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
            #if NETWORK_DEBUG
                if (block) {
                    [Train parseTrainDetailsData:[NSJSONSerialization JSONObjectWithResourceJSONFile:@"TestTrainDetailResponse"] forObject:self];
                    
                    block(nil);
                }
            #else
                if (block) {
                    block(error);
                }
            #endif
            }];
}

+(void)parseTrainDetailsData:(id)JSON forObject:(Train*)train {
    NSDictionary *trainDetailsFromResponse = JSON[@"look"][@"singletrain"][0];
    
    [train updateTrainDetailsWithAttributes:trainDetailsFromResponse];
}

@end
