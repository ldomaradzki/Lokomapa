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
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"

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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [cellJourney. arrivalTime getHourMinuteString], cellJourney.destinationStation];
    cell.detailTextLabel.text = cellJourney.train;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([cellJourney getDelayString].length > 0) {
        UILabel *delayLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 21, 100, 24)];
        delayLabel.font = [UIFont systemFontOfSize:12];
        delayLabel.textColor = [UIColor blackColor];
        delayLabel.textAlignment = NSTextAlignmentRight;
        delayLabel.text = [cellJourney getDelayString];
        
        [cell.contentView addSubview:delayLabel];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Journey *cellJourney = self.schedule.journeys[indexPath.row];
    
    [UIActionSheet
     presentOnView:self.view
     withTitle:cellJourney.destinationStation
     otherButtons:@[@"Send to clipboard", @"Set notification"]
     onCancel:nil
     onClickedButton:^(UIActionSheet *actionSheet, NSUInteger buttonNumber) {
         switch (buttonNumber) {
             case 1: {
                 // clipboard
                 [self clipboardActionsForJourney:cellJourney];
                 break;
             }
                 
             case 2: {
                 // notification
                 
                 break;
             }
                 
             default:
                 break;
         }
     }];
}

-(void)clipboardActionsForJourney:(Journey*)journey {
    NSString *pasteString =
    [NSString stringWithFormat:@"%@: %@ (-> %@) @ %@",
     self.station.name, journey.train, journey.destinationStation, [journey.arrivalTime getHourMinuteString]];
    if ([journey getDelayString].length > 0) {
        pasteString = [pasteString stringByAppendingFormat:@" (%@)", [journey getDelayString]];
    }
    
    [[UIPasteboard generalPasteboard] setString:pasteString];
    
    [UIAlertView
     showWithTitle:@"Saved to clipboard"
     message:pasteString
     cancelButtonTitle:@"Hide"
     otherButtonTitles:@[@"Send message"]
     tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == 1) {
             if ([MFMessageComposeViewController canSendText]) {
                 MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
                 messageComposeViewController.body = pasteString;
                 messageComposeViewController.messageComposeDelegate = self;
                 
                 [self presentViewController:messageComposeViewController animated:YES completion:nil];
             }
         }
     }];

}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
