//
//  TrainDetailsViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 02.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "TrainDetailsViewController.h"
#import "Train.h"

@implementation TrainDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateBasicLabels];
    
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
    self.nameLabel.text = self.train.name;
    self.idLabel.text = self.train.trainId;
}

-(void)updateAdditionalDetails {
    
}

@end
