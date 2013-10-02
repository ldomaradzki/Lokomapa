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
        NSDateFormatter *hourFormatter = [NSDateFormatter new];
        [hourFormatter setDateFormat:@"HH:mm"];
        
        self.stopName = attributes[[@"stopname" addPrefix:prefix]];
        
        self.departureTime = [hourFormatter dateFromString:attributes[[@"dep" addPrefix:prefix]]];
        self.arrivalTime = [hourFormatter dateFromString:attributes[[@"arr" addPrefix:prefix]]];
        
        self.departureDelay = @([attributes[[@"dep_d" addPrefix:prefix]] intValue]);
        self.arrivalDelay = @([attributes[[@"arr_d" addPrefix:prefix]] intValue]);
    }
    return self;
}

@end

@implementation Train

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stopName = attributes[@"lstopname"];
    self.name = attributes[@"name"];
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
                NSMutableArray *trainsFromResponse = JSON[@"look"][@"trains"];
                NSMutableArray *trains = [NSMutableArray arrayWithCapacity:trainsFromResponse.count];
                for (NSDictionary *attributes in trainsFromResponse) {
                    Train *train = [[Train alloc] initWithAttributes:attributes];
                    [trains addObject:train];
                }
                
                if (block) {
                    block([NSArray arrayWithArray:trains], nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([NSArray array], error);
                }
            }];
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
                NSDictionary *trainDetailsFromResponse = JSON[@"look"][@"singletrain"][0];
                
                [self updateTrainDetailsWithAttributes:trainDetailsFromResponse];
                
                if (block) {
                    block(nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block(error);
                }
            }];
}

@end
