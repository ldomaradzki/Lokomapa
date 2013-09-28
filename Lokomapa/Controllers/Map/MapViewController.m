//
//  MapViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 24.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "MapViewController.h"
#import "Station.h"
#import "Schedule.h"

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [Schedule stationSchedule:@(5101118) withBlock:^(Schedule *schedule, NSError *error) {
        NSLog(@"%@ %@", schedule, error);
    }];
    
    [Station stationsWithBlock:^(NSArray *stations, NSError *error) {
        NSLog(@"%@ %@", stations, error);
    }];
}

@end
