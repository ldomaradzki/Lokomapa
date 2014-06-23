//
//  SitkolAPIClient.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "SitkolAPIClient.h"
#import "AFNetworkActivityIndicatorManager.h"

static NSString * const SitkolAPIClientURLString = @"http://rozklad.sitkol.pl";

@interface LDJSONResponseSerializer : AFJSONResponseSerializer {}
@end

@implementation LDJSONResponseSerializer

-(BOOL)validateResponse:(NSHTTPURLResponse *)response
                   data:(NSData *)data
                  error:(NSError *__autoreleasing *)error {
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([dataString hasPrefix:@"journeysObj"]) {

        return NO;
    }
    
    return YES;
}

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    dataString = [dataString stringByReplacingOccurrencesOfString:@"journeysObj = " withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\\" withString:@" "];
    
    return [super responseObjectForResponse:response data:[dataString dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

@end


@implementation SitkolAPIClient

+ (instancetype)sharedClient {
    static SitkolAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SitkolAPIClient alloc] initWithBaseURL:[NSURL URLWithString:SitkolAPIClientURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        LDJSONResponseSerializer *responseSerializer = [[LDJSONResponseSerializer alloc] init];
        NSMutableSet *acceptableContentTypes = [responseSerializer.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"text/html"];
        responseSerializer.acceptableContentTypes = acceptableContentTypes;
        self.responseSerializer = responseSerializer;
        [self.requestSerializer setValue:@"Lokomapa" forHTTPHeaderField:@"User-Agent"];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
    }
    return self;
}

@end
