//
//  TrainDetailsViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 02.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Train;

@interface TrainDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    int numberOfRows;
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, strong) Train *train;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(void)prepareForTrain:(Train*)train;

@end
