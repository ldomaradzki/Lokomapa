//
//  ScheduleViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@interface ScheduleViewController : UIViewController

@property (nonatomic, strong) Station *station;

-(void)prepareForStation:(Station*)scheduleForStation;

@end
