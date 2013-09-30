//
//  MapViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 24.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    Station *stationForSchedule;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *stationsTrainsSegmentedControl;

@end
