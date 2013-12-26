//
//  SettingsViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 13.11.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "SettingsViewController.h"
#import "FAKFontAwesome.h"

#define ICON_SIZE 17


@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Settings";

    fontAwesomes = @[@[[FAKFontAwesome mapMarkerIconWithSize:ICON_SIZE], [FAKFontAwesome clockOIconWithSize:ICON_SIZE], [FAKFontAwesome bellOIconWithSize:ICON_SIZE]], @[[FAKFontAwesome linkIconWithSize:ICON_SIZE], [FAKFontAwesome questionIconWithSize:ICON_SIZE], [FAKFontAwesome githubIconWithSize:ICON_SIZE]]];
}

-(UIImage *)fontAwesomeImageWithIcon:(FAKFontAwesome*)fontAwesome {
    [fontAwesome setAttributes:@{NSForegroundColorAttributeName: RGBA(91, 140, 169, 1)}];
    return [fontAwesome imageWithSize:CGSizeMake(30, 30)];
}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 3;
    if (section == 1)
        return 3;
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
 
    if (indexPath.section == 0) {
        cell.textLabel.text =
        @[@"Showing pin title",
          @"Auto update", @"Clear all notifications"][indexPath.row];
        cell.detailTextLabel.text = @[@"", @"10 sec timer", @""][indexPath.row];
        
        if (indexPath.row < 2) {
            UISwitch *cellSwitch = [[UISwitch alloc] init];
            cellSwitch.onTintColor = RGBA(91, 140, 169, 1);
            cell.accessoryView = cellSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    if (indexPath.section == 1) {
        cell.textLabel.text = @[@"SITkol - rozklad.sitkol.pl", @"Have a question?", @"About"][indexPath.row];
        cell.detailTextLabel.text = @[@"Data provider", @"Send me an e-mail!", @"Know more about this app"][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.indentationWidth = 20;
    cell.indentationLevel = 1;
    
    UIImageView *fontAwesomeImageView = [[UIImageView alloc] init];
    fontAwesomeImageView.image = [self fontAwesomeImageWithIcon:fontAwesomes[indexPath.section][indexPath.row]];
    fontAwesomeImageView.contentMode = UIViewContentModeCenter;
    fontAwesomeImageView.frame = CGRectMake(0, 0, 35, 44);
    
    [cell.contentView addSubview:fontAwesomeImageView];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { // SITkol
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rozklad.sitkol.pl/"]];
        }
        
        if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:lukasz.domaradzki@gmail.com"]];
        }
        
        if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/ldomaradzki/Lokomapa"]];
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"General settings", @"Application info"][section];
}


@end
