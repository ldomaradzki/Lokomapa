//
//  SettingsViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 13.11.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Settings";
}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
 
    if (indexPath.section == 0) {
        cell.textLabel.text =
        @[@"Pin title",
          @"Auto update"][indexPath.row];
        cell.detailTextLabel.text =
        @[@"Showing pin title next to pin image on map.",
          @"Every 10 seconds map is updated with new information"][indexPath.row];
        
        UISwitch *cellSwitch = [[UISwitch alloc] init];
        cell.accessoryView = cellSwitch;
    }
    
    if (indexPath.section == 1) {
//        cell.textLabel.text = @[@"SITKol - "]
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"General settings", @"Application info"][section];
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end
