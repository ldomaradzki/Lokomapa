//
//  MapViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 24.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "MapViewController.h"

#import "StationAnnotation.h"
#import "TrainAnnotation.h"

#import "StationAnnotationView.h"
#import "ScheduleViewController.h"
#import "TrainDetailsViewController.h"
#import "Station.h"
#import "Train.h"
#import "UIAlertView+AFNetworking.h"

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(54.43574854705889f, 18.56841092715129), MKCoordinateSpanMake(0.5f, 0.5f))];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    [self.navigationController.navigationBar setBarTintColor:RGBA(91, 140, 169, 1)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.mapView.showsUserLocation = NO;
}


- (void)getStations:(MKMapView *)mapView {
    if (self.lastTask) {
        [self.lastTask cancel];
    }
    
    NSURLSessionDataTask *task = [Station stationsInRegion:mapView.region withBlock:^(NSArray *stations, NSError *error) {
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
    self.lastTask = task;
}

- (void)getTrains:(MKMapView *)mapView {
    if (self.lastTask) {
        [self.lastTask cancel];
    }
    
    NSURLSessionDataTask *task = [Train trainsInRegion:mapView.region withBlock:^(NSArray *trains, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *annotationsDictionary = [NSMutableDictionary dictionaryWithCapacity:mapView.annotations.count];
            for (id<MKAnnotation> annotation in mapView.annotations) {
                if ([annotation isKindOfClass:[TrainAnnotation class]])
                    annotationsDictionary[[(TrainAnnotation*)annotation train].trainId] = annotation;
            }
            
            
            for (Train *train in trains) {
                if ([[annotationsDictionary allKeys] containsObject:train.trainId]) {
                    [(TrainAnnotation*)annotationsDictionary[train.trainId] setTrain:train];
                    [annotationsDictionary removeObjectForKey:train.trainId];
                } else {
                    TrainAnnotation *newTrainAnnotation = [[TrainAnnotation alloc] init];
                    newTrainAnnotation.train = train;
                    [mapView addAnnotation:newTrainAnnotation];
                }
            }
            
            for (id key in [annotationsDictionary allKeys]) {
                [mapView removeAnnotation:annotationsDictionary[key]];
            }
        });
    }];
    self.lastTask = task;
}

#pragma mark - MapView

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"%f", mapView.region.span.latitudeDelta);
    
    if (mapView.region.span.latitudeDelta < 0.7f) {
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
    else if (mapView.region.span.latitudeDelta > 1.0f) {
        [mapView removeAnnotations:mapView.annotations];
    }
    
    if (mapView.region.span.latitudeDelta < 0.3f) {
        for (id<MKAnnotation> annotation in mapView.annotations) {
            [(StationAnnotationView*)[mapView viewForAnnotation:annotation] animateWithDelay:0.02*[mapView.annotations indexOfObject:annotation]];
        }
    }
    else {
        for (id<MKAnnotation> annotation in mapView.annotations) {
            [(StationAnnotationView*)[mapView viewForAnnotation:annotation] hideWithDelay:0.02*[mapView.annotations indexOfObject:annotation]];
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[StationAnnotation class]]) {
        StationAnnotationView *view = [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[(StationAnnotation*)annotation station].name];
        [view prepareCustomViewWithTitle:[(StationAnnotation*)annotation station].name];
        return view;
    }
    else if ([annotation isKindOfClass:[TrainAnnotation class]]) {
        StationAnnotationView *view = [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[(TrainAnnotation*)annotation train].name];
        [view prepareCustomViewWithTitle:[(TrainAnnotation*)annotation train].name];
        return view;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[StationAnnotation class]]) {
        stationForSchedule = [(StationAnnotation*)view.annotation station];
        [self performSegueWithIdentifier:@"map2schedule" sender:self.view];
    }
    else if ([view.annotation isKindOfClass:[TrainAnnotation class]]) {
        trainForTrainDetails = [(TrainAnnotation*)view.annotation train];
        [self performSegueWithIdentifier:@"map2train" sender:self.view];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (StationAnnotationView *annotationView in views) {
        annotationView.alpha = 0.0f;
        [UIView
         animateWithDuration:0.3f
         animations:^{
             annotationView.alpha = 1.0f;
         }
         completion:^(BOOL finished) {
             if (finished) {
                 if (mapView.region.span.latitudeDelta < 0.3f) {
                     [annotationView animateWithDelay:0.02*[views indexOfObject:annotationView]];
                 }
             }
         }];
    }
}

#pragma mark - Storyboard segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ScheduleViewController class]]) {
        ScheduleViewController *scheduleViewController = segue.destinationViewController;
        [scheduleViewController prepareForStation:stationForSchedule];
    }
    else if ([segue.destinationViewController isKindOfClass:[TrainDetailsViewController class]]) {
        TrainDetailsViewController *trainDetailsViewController = segue.destinationViewController;
        [trainDetailsViewController prepareForTrain:trainForTrainDetails];
    }
}

#pragma mark - IB methods

- (IBAction)handleStationsTrainSwitchChange:(UISegmentedControl *)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self mapView:self.mapView regionDidChangeAnimated:NO];
}

@end
