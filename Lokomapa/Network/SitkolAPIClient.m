//
//  SitkolAPIClient.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "SitkolAPIClient.h"

static NSString * const SitkolAPIClientURLString = @"http://rozklad.sitkol.pl";

@implementation SitkolAPIClient

+ (instancetype)sharedClient {
    static SitkolAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SitkolAPIClient alloc] initWithBaseURL:[NSURL URLWithString:SitkolAPIClientURLString]];
    });
    
    return _sharedClient;
}

@end
