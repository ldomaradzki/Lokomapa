//
//  AppDelegate.m
//  Lokomapa
//
//  Created by ldomaradzki on 24.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showingPinTitle"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}
							
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (application.applicationState == UIApplicationStateInactive ) {
        [application cancelLocalNotification:notification];
    }
    else if(application.applicationState == UIApplicationStateActive )  {
        [application cancelLocalNotification:notification];
        [[[UIAlertView alloc]
          initWithTitle:@"Notification"
          message:notification.alertBody
          delegate:nil
          cancelButtonTitle:@"Dismiss"
          otherButtonTitles:nil] show];
    }
}

@end
