//
//  TrainDetailsViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 02.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Train;

@interface TrainDetailsViewController : UIViewController

@property (nonatomic, strong) Train *train;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *idLabel;


-(void)prepareForTrain:(Train*)train;

@end
