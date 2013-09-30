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
#import "Station.h"
#import "Train.h"

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(54.43574854705889f, 18.56841092715129), MKCoordinateSpanMake(0.5f, 0.5f))];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    [self.navigationController.navigationBar setBarTintColor:RGBA(91, 140, 169, 1)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.rotateEnabled = NO;
}


- (void)getStations:(MKMapView *)mapView {
    [Station stationsInRegion:mapView.region withBlock:^(NSArray *stations, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *annotationsDictionary = [NSMutableDictionary dictionaryWithCapacity:mapView.annotations.count];
            for (StationAnnotation *annotation in mapView.annotations) {
                annotationsDictionary[annotation.station.externalId] = annotation;
            }
            
            
            for (Station *station in stations) {
                if ([[annotationsDictionary allKeys] containsObject:station.externalId]) {
                    [annotationsDictionary removeObjectForKey:station.externalId];
                } else {
                    StationAnnotation *newStationAnnotation = [[StationAnnotation alloc] init];
                    newStationAnnotation.station = station;
                    [mapView addAnnotation:newStationAnnotation];
                }
            }
            
            for (id key in [annotationsDictionary allKeys]) {
                [mapView removeAnnotation:annotationsDictionary[key]];
            }
        });
    }];
}

- (void)getTrains:(MKMapView *)mapView {
    [Train trainsInRegion:mapView.region withBlock:^(NSArray *trains, NSError *error) {
        NSLog(@"%@", trains);
    }];
}

#pragma mark - MapView

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (mapView.region.span.latitudeDelta < 0.6f) {
        switch (self.stationsTrainsSegmentedControl.selectedSegmentIndex) {
            case 0: {
                [self getStations:mapView];
                break;
            }
                
            case 1: {
                [self getTrains:mapView];
                break;
            }
                
            default:
                break;
        }
        
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"STATION_ANNOTATION"];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    stationForSchedule = [(StationAnnotation*)view.annotation station];
    [self performSegueWithIdentifier:@"map2schedule" sender:self.view];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV;
    for (aV in views) {
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }

        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 30, aV.frame.size.width, aV.frame.size.height);
        aV.alpha = 0.0f;

        [UIView animateWithDuration:0.2 delay:0.01*[views indexOfObject:aV] options: UIViewAnimationOptionCurveEaseInOut animations:^{
            aV.frame = endFrame;
            aV.alpha = 1.0f;
        }completion:nil];
    }
}

#pragma mark - Storyboard segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ScheduleViewController class]]) {
        ScheduleViewController *scheduleViewController = segue.destinationViewController;
        [scheduleViewController prepareForStation:stationForSchedule];
    }
}

@end
