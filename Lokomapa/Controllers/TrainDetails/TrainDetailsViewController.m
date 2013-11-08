//
//  TrainDetailsViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 02.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "TrainDetailsViewController.h"
#import "Train.h"
#import "TrainStopDetailsCell.h"
#import "TrainScheduleViewController.h"

#define TrainStopDetailsCellReuseIdentifier @"TRAIN_STOP_DETAILS_CELL"

@implementation TrainDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TrainStopDetailsCell" bundle:nil] forCellReuseIdentifier:TrainStopDetailsCellReuseIdentifier];
    
    [self updateBasicLabels];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidesWhenStopped = YES;
    [indicatorView startAnimating];
    indicatorView.center = self.view.center;
    [self.view addSubview:indicatorView];
    
    numberOfRows = 0;
    [self updateData];
}

-(void)viewDidAppear:(BOOL)animated {
    self.title = self.train.name;
}

-(void)updateData {
    [self.train trainDetailsWithBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicatorView removeFromSuperview];
            [self updateAdditionalDetails];
        });
        
    }];
}

-(void)prepareForTrain:(Train *)train {
    self.train = train;
    [self updateData];
}

-(void)updateBasicLabels {
    self.title = self.train.name;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
}

-(void)updateAdditionalDetails {
    numberOfRows = 4;
    [self.tableView reloadData];
}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (numberOfRows > 0)
        return numberOfRows + 1;
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Check full schedule";
        cell.textLabel.textColor = RGBA(91, 140, 169, 1);
        
        return cell;
    }
    else {
        TrainStopDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:TrainStopDetailsCellReuseIdentifier forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        
        [cell prepareCellWithTrainStop:[self.train sortedTrainStopForPlace:indexPath.row] atIndex:indexPath];
        
        return cell;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        [self performSegueWithIdentifier:@"train2web" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TrainScheduleViewController *trainSchedule = (TrainScheduleViewController*)segue.destinationViewController;
    
    trainSchedule.trainId = self.train.trainId;
}

@end
