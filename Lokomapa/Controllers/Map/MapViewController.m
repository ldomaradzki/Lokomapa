//
//  MapViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 24.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "MapViewController.h"

#import "StationAnnotation.h"
#import "StationAnnotationView.h"
#import "ScheduleViewController.h"

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(54.43574854705889f, 18.56841092715129), MKCoordinateSpanMake(0.5f, 0.5f))];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    [self.navigationController.navigationBar setBarTintColor:RGBA(49, 95, 121, 1)];
    
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (!animated) {
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
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"STATION_ANNOTATION"];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    stationForSchedule = [(StationAnnotation*)view.annotation station];
    [self performSegueWithIdentifier:@"map2schedule" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ScheduleViewController class]]) {
        ScheduleViewController *scheduleViewController = segue.destinationViewController;
        [scheduleViewController prepareForStation:stationForSchedule];
    }
}

@end
