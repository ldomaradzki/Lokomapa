//
//  Schedule.m
//  Lokomapa
//
//  Created by ldomaradzki on 28.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "Schedule.h"
#import "SitkolAPIClient.h"

static NSString * const SitkolAPIStationGETURLString = @"bin/stboard.exe/pn";

@implementation NSString (decodeHTMLentities)

- (NSString *)stringByDecodingXMLEntities {
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            return result;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&nbsp;" intoString:NULL])
            [result appendString:@" "];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            
            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];
                
                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
            }
        }
        else {
            NSString *amp;
            
            [scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
            [result appendString:amp];
        }
    }
    while (![scanner isAtEnd]);

    return result;
}

@end

@implementation Journey

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH:mm"];
    
    self.destinationStation = [attributes[@"dest"] stringByDecodingXMLEntities];
    self.delay = attributes[@"delay"];
    self.journeyId = attributes[@"id"];
    self.train = attributes[@"product"];
    self.arrivalTime = [hourFormatter dateFromString:attributes[@"time"]];
    
    return self;
}

@end

@implementation Schedule

-(instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSMutableArray *journeys = [NSMutableArray arrayWithCapacity:[attributes[@"journey"] count]];
    for (NSDictionary *journeyAttributes in attributes[@"journey"]) {
        Journey *journey = [[Journey alloc] initWithAttributes:journeyAttributes];
        [journeys addObject:journey];
    }

    self.name = attributes[@"name"];
    self.journeys = [NSArray arrayWithArray:journeys];
    
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ (journeys count:%d)", self.name, self.journeys.count];
}

+ (NSURLSessionDataTask*)stationSchedule:(NSNumber*)stationId withBlock:(void (^)(Schedule *schedule, NSError *error))block {
    
    NSDictionary *parameters =
    @{
      @"boardType": @"dep",
      @"disableEquivs": @"yes",
      @"ignoreMasts": @"yes",
      @"selectDate": @"today",
      @"time": @"now",
      @"productsFilter": @"1111111111",
      @"maxJourneys": @"20",
      @"start": @"1343079701735",
      @"ajax": @"yes",
      
      @"input": [stationId stringValue]
      };
    
    return [[SitkolAPIClient sharedClient]
            GET:SitkolAPIStationGETURLString
            parameters:parameters
            success:^(NSURLSessionDataTask *task, id JSON) {
                NSDictionary *attributesFromResponse = JSON[@"stBoard"];
                Schedule *schedule = [[Schedule alloc] initWithAttributes:attributesFromResponse];
                if (block) {
                    block(schedule, nil);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([Schedule new], error);
                }
            }];
}

@end
