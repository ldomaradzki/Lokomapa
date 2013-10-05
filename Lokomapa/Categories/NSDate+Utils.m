//
//  NSDate+Formatter.m
//  Lokomapa
//
//  Created by ldomaradzki on 05.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

-(NSString*)getHourMinuteString {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    return [dateFormatter stringFromDate:self];
}

@end
