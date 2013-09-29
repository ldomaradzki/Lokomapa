//
//  StationAnnotation.h
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Station.h"

@interface StationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) Station *station;

@end
