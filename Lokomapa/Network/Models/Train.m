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

    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ -> %@", self.name, self.stopName];
}

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

@end
