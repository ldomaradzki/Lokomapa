//
//  NSString+DateFormatter.h
//  Lokomapa
//
//  Created by ldomaradzki on 05.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

-(NSDate*)getHourMinuteDate;
-(NSString*)cleanWhitespace;
-(NSString *)stringByDecodingXMLEntities;
@end
