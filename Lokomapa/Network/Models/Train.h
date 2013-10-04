//
//  Train.h
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainStop : NSObject

@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSDate *departureTime;
@property (nonatomic, strong) NSNumber *departureDelay;
@property (nonatomic, strong) NSDate *arrivalTime;
@property (nonatomic, strong) NSNumber *arrivalDelay;

-(instancetype)initWithPrefix:(NSString*)prefix andAttributes:(NSDictionary*)attributes;

@end

@interface Train : NSObject

@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *trainId;
@property (nonatomic, strong) CLLocation *coords;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSNumber *direction;
@property (nonatomic, strong) NSNumber *passedPercent;
@property (nonatomic, strong) NSNumber *prodClass;
@property (nonatomic, strong) TrainStop *firstStop;
@property (nonatomic, strong) TrainStop *nowStop;
@property (nonatomic, strong) TrainStop *passedStop;
@property (nonatomic, strong) TrainStop *lastStop;

- (instancetype)initWithAttributes:(NSDictionary*)attributes;
- (TrainStop*)sortedTrainStopForPlace:(int)number;

+ (NSURLSessionDataTask*)trainsInRegion:(MKCoordinateRegion)region withBlock:(void (^)(NSArray *trains, NSError *error))block;
- (NSURLSessionDataTask*)trainDetailsWithBlock:(void (^)(NSError *error))block;

@end
