//
//  SettingsViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 13.11.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
