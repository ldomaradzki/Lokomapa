//
//  SettingsViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 13.11.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *fontAwesomes;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolbarCloseButton;
@property (weak, nonatomic) IBOutlet UILabel *toolbarTitle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)dismissModalWindow:(UIBarButtonItem *)sender;

@end
