//
//  TrainStopDetailsCell.h
//  Lokomapa
//
//  Created by ldomaradzki on 04.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrainStop;

@interface TrainStopDetailsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *arrivalLabel;
@property (strong, nonatomic) IBOutlet UILabel *departureLabel;

@property (strong, nonatomic) IBOutlet UIView *upperLineView;
@property (strong, nonatomic) IBOutlet UIView *bottomLineView;


-(void)prepareCellWithTrainStop:(TrainStop*)trainStop  atIndex:(NSIndexPath*)indexPath;

@end
