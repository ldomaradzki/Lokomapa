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
#import <Social/Social.h>

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
        
        [self setStationColors];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sender) {
                if ([sender isKindOfClass:[UIActivityIndicatorView class]]) {
                    [sender removeFromSuperview];
                }
            }
            [self.tableView reloadData];
        });
    }];
}

-(void)setStationColors {
    NSMutableArray *stationsStringArray = [NSMutableArray array];
    for (Journey *journey in self.schedule.journeys) {
        [stationsStringArray addObject:journey.destinationStation];
    }
    
    NSArray *singleStations = [[NSSet setWithArray:stationsStringArray] allObjects];
    
    stationColors = [NSDictionary dictionaryWithObjects:[self getRandomColorsArrayForCount:singleStations.count] forKeys:singleStations];

}

-(NSArray *)getRandomColorsArrayForCount:(int)count {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    
    for (int k = 0; k < count; k++) {
        [array addObject:RGBA(arc4random()%255, arc4random()%255, arc4random()%255, 1)];
    }
    
    return array;
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
    
    UIView *colorBar = [[UIView alloc] initWithFrame:CGRectMake(3, 10, 10, 10)];
    colorBar.backgroundColor = stationColors[cellJourney.destinationStation];
    colorBar.layer.cornerRadius = 5;
    [cell.contentView addSubview:colorBar];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentJourney = self.schedule.journeys[indexPath.row];
    
    firstActionSheet = [[UIActionSheet alloc] initWithTitle:[self getInfoStringForJourney:currentJourney] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send or share", @"Set notification", nil];
    [firstActionSheet showInView:self.view];
}

-(NSString*)getInfoStringForJourney:(Journey*)journey {
    NSString *pasteString =
    [NSString stringWithFormat:@"%@: %@ (-> %@) @ %@",
     self.station.name, journey.train, journey.destinationStation, [journey.arrivalTime getHourMinuteString]];
    if ([journey getDelayString].length > 0) {
        pasteString = [pasteString stringByAppendingFormat:@" (%@)", [journey getDelayString]];
    }
    return pasteString;
}

-(void)clipboardActionsForJourney:(Journey*)journey {
    [[UIPasteboard generalPasteboard] setString:[self getInfoStringForJourney:journey]];
    
    shareActionSheet = [[UIActionSheet alloc] initWithTitle:[self getInfoStringForJourney:journey] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send SMS/iMessage", @"Share of Facebook", @"Share on Twitter", nil];
    [shareActionSheet showInView:self.view];
}

-(void)notificationActionForJourney:(Journey*)journey {
    notificationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Set notification for this train before:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"5 minutes", @"10 minutes", @"20 minutes", @"30 minutes", @"1 hour", nil];
    [notificationActionSheet showInView:self.view];
}

#pragma mark - Actionsheet methods

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == firstActionSheet) {
        switch (buttonIndex) {
            case 0: {
                [self clipboardActionsForJourney:currentJourney];
                break;
            }
                
            case 1: {
                [self notificationActionForJourney:currentJourney];
                break;
            }
                
            default:
                break;
        }
    }
    
    if (actionSheet == shareActionSheet) {
        switch (buttonIndex) {
             case 0: {
                 [self sendSMSMessage:[self getInfoStringForJourney:currentJourney]];
                 break;
             }

             case 1: {
                 [self sendSocialMessage:[self getInfoStringForJourney:currentJourney] forType:SLServiceTypeFacebook];
                 break;
             }

             case 2: {
                 [self sendSocialMessage:[self getInfoStringForJourney:currentJourney] forType:SLServiceTypeTwitter];
                 break;
             }
                 
             default:
                 break;
         }
    }
    
    if (actionSheet == notificationActionSheet) {
        switch (buttonIndex) {
            case 0: {
                [self setNotificationTime:@5 forJourney:currentJourney];
                break;
            }
                
            case 1: {
                [self setNotificationTime:@10 forJourney:currentJourney];
                break;
            }
                
            case 2: {
                [self setNotificationTime:@20 forJourney:currentJourney];
                break;
            }
                
            case 3: {
                [self setNotificationTime:@30 forJourney:currentJourney];
                break;
            }
                
            case 4: {
                [self setNotificationTime:@60 forJourney:currentJourney];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Local notification

-(void)setNotificationTime:(NSNumber*)time forJourney:(Journey*)journey {
    UILocalNotification *localNotification = [UILocalNotification new];
    
    localNotification.repeatInterval = 0;
    localNotification.alertBody = @"Stuff";
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - Social method

-(void)sendSocialMessage:(NSString*)message forType:(NSString*)type {
    if ([SLComposeViewController isAvailableForServiceType:type]) {
        SLComposeViewController *facebookComposeViewController = [SLComposeViewController composeViewControllerForServiceType:type];
        
        [facebookComposeViewController setInitialText:message];
        [self presentViewController:facebookComposeViewController animated:YES completion:nil];
    }
}


#pragma mark - Message method & delegate

-(void)sendSMSMessage:(NSString*)message {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
        messageComposeViewController.body = message;
        messageComposeViewController.messageComposeDelegate = self;
        
        [self presentViewController:messageComposeViewController animated:YES completion:nil];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
