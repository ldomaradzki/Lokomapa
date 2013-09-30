//
//  SitkolAPIClient.h
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "SitkolCoords.h"

@interface SitkolAPIClient : AFHTTPSessionManager

+(instancetype)sharedClient;

@end
