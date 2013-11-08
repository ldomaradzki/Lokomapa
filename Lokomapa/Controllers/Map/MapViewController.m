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
#import "MKMapView+ZoomLevel.h"
#import "ZoomIndicatorView.h"
#import "FontAwesomeKit/FAKFontAwesome.h"
#import "MCPanelViewController.h"

@interface MCPanelSegue : UIStoryboardSegue

@property (nonatomic, strong) MCPanelViewController *panelViewController;

@end

@implementation MCPanelSegue

-(id)initWithIdentifier:(NSString *)identifier
                 source:(UIViewController *)source
            destination:(UIViewController *)destination {
    
    self.panelViewController = [[MCPanelViewController alloc] initWithRootViewController:destination];
    self.panelViewController.masking = NO;
    
    return [super initWithIdentifier:identifier source:source destination:destination];
}

-(void)perform {
    [self.panelViewController presentInViewController:[(UIViewController*)self.sourceViewController navigationController] withDirection:MCPanelAnimationDirectionRight];
}

@end

@interface MKMapView (betterZoomLevel)

+ (double)longitudeToPixelSpaceX:(double)longitude;
+ (double)latitudeToPixelSpaceY:(double)latitude;

@end

@implementation MKMapView (betterZoomLevel)

- (double) betterZoomLevel {
    MKCoordinateRegion region = self.region;
    
    double centerPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude];
    double topLeftPixelX = [MKMapView longitudeToPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2];
    
    double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
    CGSize mapSizeInPixels = self.bounds.size;
    double zoomScale = scaledMapWidth / mapSizeInPixels.width;
    double zoomExponent = log(zoomScale) / log(2);
    double zoomLevel = 20 - zoomExponent;
    
    return zoomLevel;
}

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

+ (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

+ (double)latitudeToPixelSpaceY:(double)latitude
{
	if (latitude == 90.0) {
		return 0;
	} else if (latitude == -90.0) {
		return MERCATOR_OFFSET * 2;
	} else {
		return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
	}
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView.showsUserLocation = YES;
    
    if (TARGET_IPHONE_SIMULATOR) {
        [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(54.43574854705889f, 18.56841092715129), MKCoordinateSpanMake(0.5f, 0.5f))];
        self.mapView.showsUserLocation = NO;
        showedInitialUserLocation = YES;
    }
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    [self.navigationController.navigationBar setBarTintColor:RGBA(91, 140, 169, 1)]; //#5B8CA9
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    
    [self addSettingsBarButton];
    [self addUserLocationButton];
    
    showedInitialUserLocation = NO;
}

-(void)addSettingsBarButton {
    FAKFontAwesome *cogIcon = [FAKFontAwesome cogIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
}

-(void)addUserLocationButton {
    FAKFontAwesome *locationIcon = [FAKFontAwesome locationArrowIconWithSize:20];
    [locationIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [locationIcon imageWithSize:CGSizeMake(20, 20)];
    locationIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [locationIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(zoomToUserLocation:)];
}

-(void)zoomToUserLocation:(BOOL)animated {
    if (self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:12 animated:animated];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // just to be sure
            [self mapView:self.mapView regionDidChangeAnimated:YES];
        });
    }
}

- (void)getStations:(MKMapView *)mapView {
    NSURLSessionDataTask *task = [Station stationsInRegion:mapView.region forZoomLevel:[mapView betterZoomLevel] withBlock:^(NSArray *stations, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *annotationsDictionary = [NSMutableDictionary dictionaryWithCapacity:mapView.annotations.count];
            for (StationAnnotation *annotation in mapView.annotations) {
                if ([annotation respondsToSelector:@selector(station)]) {
                    annotationsDictionary[annotation.station.externalId] = annotation;
                }
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
    NSURLSessionDataTask *task = [Train trainsInRegion:mapView.region withBlock:^(NSArray *trains, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *annotationsDictionary = [NSMutableDictionary dictionaryWithCapacity:mapView.annotations.count];
            for (TrainAnnotation* annotation in mapView.annotations) {
                if ([annotation respondsToSelector:@selector(train)]) {
                    annotationsDictionary[[annotation train].trainId] = annotation;
                }
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

#pragma mark - ZoomLevel watcher

-(void)startWatchingZoomLevel {
    zoomLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateZoomLevel) userInfo:nil repeats:YES];
    currentZoomLevel = [self.mapView betterZoomLevel];
    double percentageLevel = 1 - ((currentZoomLevel - ZOOM_LEVEL_CEILING) / 12);
    [self.zoomIndicator updateZoomLevel:percentageLevel];
    
    [self.zoomIndicator show];
}

-(void)updateZoomLevel {
    if (currentZoomLevel != [self.mapView betterZoomLevel]) {
        currentZoomLevel = [self.mapView betterZoomLevel];
        double percentageLevel = 1 - ((currentZoomLevel - ZOOM_LEVEL_CEILING) / 12);
        [self.zoomIndicator updateZoomLevel:percentageLevel];
        
        if (percentageLevel > 1.0f) {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
    }
}

-(void)stopWatchingZoomLevel {
    if (zoomLevelTimer) {
        [zoomLevelTimer invalidate];
        zoomLevelTimer = nil;
    }
    currentZoomLevel = [self.mapView betterZoomLevel];
    double percentageLevel = 1 - ((currentZoomLevel - ZOOM_LEVEL_CEILING) / 12);
    [self.zoomIndicator updateZoomLevel:percentageLevel];
    
    [self.zoomIndicator hide];
}

#pragma mark - MapView

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self startWatchingZoomLevel];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self stopWatchingZoomLevel];
    
    if ([mapView betterZoomLevel] > ZOOM_LEVEL_CEILING) {
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
    else {
        NSMutableArray *annotationsToRemove = [mapView.annotations mutableCopy] ;
        [annotationsToRemove removeObject:mapView.userLocation] ;
        [mapView removeAnnotations:annotationsToRemove] ;
    }
    
    if ([mapView betterZoomLevel] > ZOOM_LEVEL_DETAILS) {
        for (id<MKAnnotation> annotation in mapView.annotations) {
            if ([[mapView viewForAnnotation:annotation] respondsToSelector:@selector(animateWithDelay:)]) {
            [(StationAnnotationView*)[mapView viewForAnnotation:annotation] animateWithDelay:0.02*[mapView.annotations indexOfObject:annotation]];
            }
        }
    }
    else {
        for (id<MKAnnotation> annotation in mapView.annotations) {
            if ([[mapView viewForAnnotation:annotation] respondsToSelector:@selector(hideWithDelay:)]) {
                [(StationAnnotationView*)[mapView viewForAnnotation:annotation] hideWithDelay:0.02*[mapView.annotations indexOfObject:annotation]];
            }
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[StationAnnotation class]]) {
        StationAnnotationView *view = [[StationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[(StationAnnotation*)annotation station].name];
        [view prepareCustomViewWithTitle:[(StationAnnotation*)annotation station].name];
        return view;
    }
    
    if ([annotation isKindOfClass:[TrainAnnotation class]]) {
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
    
    if ([view.annotation isKindOfClass:[TrainAnnotation class]]) {
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
                 if ([mapView betterZoomLevel] > ZOOM_LEVEL_DETAILS) {
                     if ([annotationView respondsToSelector:@selector(animateWithDelay:)]) {
                         [annotationView animateWithDelay:0.02*[views indexOfObject:annotationView]];
                     }
                 }
             }
         }];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!showedInitialUserLocation) {
        if (self.mapView.userLocation.location.verticalAccuracy < 100.0f) {
            showedInitialUserLocation = YES;
            [self zoomToUserLocation:NO];
        }
    }
}

#pragma mark - Storyboard segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationViewController = segue.destinationViewController;
    
    if ([destinationViewController isKindOfClass:[UINavigationController class]])
        destinationViewController = [(UINavigationController*)destinationViewController viewControllers][0];
    
    if ([destinationViewController isKindOfClass:[ScheduleViewController class]]) {
        ScheduleViewController *scheduleViewController = (ScheduleViewController*)destinationViewController;
        [scheduleViewController prepareForStation:stationForSchedule];
    }
    else if ([destinationViewController isKindOfClass:[TrainDetailsViewController class]]) {
        TrainDetailsViewController *trainDetailsViewController = (TrainDetailsViewController*)destinationViewController;
        [trainDetailsViewController prepareForTrain:trainForTrainDetails];
    }
}

#pragma mark - IB methods

- (IBAction)handleStationsTrainSwitchChange:(UISegmentedControl *)sender {
    NSMutableArray *annotationsToRemove = [self.mapView.annotations mutableCopy] ;
    [annotationsToRemove removeObject:self.mapView.userLocation] ;
    [self.mapView removeAnnotations:annotationsToRemove] ;
    
    [self mapView:self.mapView regionDidChangeAnimated:NO];
}

@end
