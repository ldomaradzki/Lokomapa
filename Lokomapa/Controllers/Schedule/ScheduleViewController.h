//
//  ScheduleViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>

@class Station, Schedule, Journey;

@interface ScheduleViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIActionSheet *firstActionSheet, *shareActionSheet, *notificationActionSheet;
    Journey *currentJourney;
    NSMutableArray *stationNames;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) Schedule *schedule;
@property (nonatomic, strong) Station *station;
@property (nonatomic, strong) NSMutableArray *filteredJourneys;
@property (weak, nonatomic) IBOutlet UIView *separatorLineView;


-(void)prepareForStation:(Station*)scheduleForStation;

@end
