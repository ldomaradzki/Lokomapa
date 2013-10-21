//
//  NSJSONSerialization+Utils.m
//  Lokomapa
//
//  Created by ldomaradzki on 21.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "NSJSONSerialization+Utils.h"

@implementation NSJSONSerialization (Utils)

+(id)JSONObjectWithResourceJSONFile:(NSString*)resourceFile {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:resourceFile ofType:@"json"]];
    
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

@end
