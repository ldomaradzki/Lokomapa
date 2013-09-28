//
//  Station.h
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject

@property (nonatomic, strong) NSNumber *externalId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *planId;
@property (nonatomic, strong) NSNumber *prodClass;
@property (nonatomic, strong) NSNumber *puic;
@property (nonatomic, strong) NSNumber *stopWeight;
@property (nonatomic, strong) NSString *urlName;
@property (nonatomic, strong) NSNumber *xCoord;
@property (nonatomic, strong) NSNumber *yCoord;
@property (nonatomic) CLLocationCoordinate2D coords;

- (instancetype)initWithAttributes:(NSDictionary*)attributes;
+ (NSURLSessionDataTask*)stationsWithBlock:(void (^)(NSArray *stations, NSError *error))block;

@end
