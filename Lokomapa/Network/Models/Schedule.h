//
//  Schedule.h
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Journey : NSObject

@property (nonatomic, strong) NSString *delay;
@property (nonatomic, strong) NSString *destinationStation;
@property (nonatomic, strong) NSString *journeyId;
@property (nonatomic, strong) NSString *train;
@property (nonatomic, strong) NSDate *arrivalTime;

- (instancetype)initWithAttributes:(NSDictionary*)attributes;

@end

@interface Schedule : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *journeys;

- (instancetype)initWithAttributes:(NSDictionary*)attributes;

+ (NSURLSessionDataTask*)stationSchedule:(NSNumber*)stationId withBlock:(void (^)(Schedule *schedule, NSError *error))block;

@end
