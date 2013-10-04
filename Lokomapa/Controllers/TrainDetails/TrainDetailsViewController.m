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

#define TrainStopDetailsCellReuseIdentifier @"TRAIN_STOP_DETAILS_CELL"

@implementation TrainDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TrainStopDetailsCell" bundle:nil] forCellReuseIdentifier:TrainStopDetailsCellReuseIdentifier];
    
    [self updateBasicLabels];
    
    numberOfRows = 0;
    [self.train trainDetailsWithBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateAdditionalDetails];
        });
        
    }];
}

-(void)prepareForTrain:(Train *)train {
    self.train = train;
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
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrainStopDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:TrainStopDetailsCellReuseIdentifier forIndexPath:indexPath];
    
    [cell prepareCellWithTrainStop:[self.train sortedTrainStopForPlace:indexPath.row] atIndex:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}

@end
