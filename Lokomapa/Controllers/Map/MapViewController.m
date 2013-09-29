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
#import "StationAnnotation.h"

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(54.43574854705889f, 18.56841092715129), MKCoordinateSpanMake(0.5f, 0.5f))];
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [Station stationsInRegion:mapView.region withBlock:^(NSArray *stations, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [mapView removeAnnotations:mapView.annotations];
            
            for (Station *station in stations) {
                StationAnnotation *newStationAnnotation = [[StationAnnotation alloc] init];
                newStationAnnotation.station = station;
                [mapView addAnnotation:newStationAnnotation];
            }
        });
        
    }];
}

@end
