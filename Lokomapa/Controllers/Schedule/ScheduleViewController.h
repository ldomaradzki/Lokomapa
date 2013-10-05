//
//  ScheduleViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>

@class Station, Schedule;

@interface ScheduleViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Schedule *schedule;
@property (nonatomic, strong) Station *station;

-(void)prepareForStation:(Station*)scheduleForStation;

@end
