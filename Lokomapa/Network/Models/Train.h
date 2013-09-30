//
//  Train.h
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Train : NSObject

@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *trainId;
@property (nonatomic, strong) CLLocation *coords;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSNumber *direction;
@property (nonatomic, strong) NSNumber *passedPercent;
@property (nonatomic, strong) NSNumber *prodClass;

- (instancetype)initWithAttributes:(NSDictionary*)attributes;
+ (NSURLSessionDataTask*)trainsInRegion:(MKCoordinateRegion)region withBlock:(void (^)(NSArray *trains, NSError *error))block;

@end
