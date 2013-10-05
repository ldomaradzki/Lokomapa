//
//  ScheduleViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "ScheduleViewController.h"
#import "Schedule.h"
#import "Station.h"

@implementation ScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.station.name;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidesWhenStopped = YES;
    [indicatorView startAnimating];
    indicatorView.center = self.view.center;
    [self.view addSubview:indicatorView];
    
    [self updateScheduleDataWithRefreshControl:indicatorView];
}

-(void)updateScheduleDataWithRefreshControl:(id)sender {
    [Schedule stationSchedule:self.station.externalId withBlock:^(Schedule *schedule, NSError *error) {
        self.schedule = schedule;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sender) {
                if ([sender isKindOfClass:[UIActivityIndicatorView class]]) {
                    [sender removeFromSuperview];
                }
                else if ([sender isKindOfClass:[UIRefreshControl class]]) {
                    [sender endRefreshing];
                }
            }
            [self.tableView reloadData];
        });
    }];
}

-(void)handleRefresh:(UIRefreshControl*)sender {
    [self updateScheduleDataWithRefreshControl:sender];
}

-(void)prepareForStation:(Station *)scheduleForStation {
    self.station = scheduleForStation;
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.schedule.journeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
    
    Journey *cellJourney = self.schedule.journeys[indexPath.row];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:cellJourney.arrivalTime], cellJourney.destinationStation];
    cell.detailTextLabel.text = cellJourney.train;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
