//
//  TrainScheduleViewController.h
//  Lokomapa
//
//  Created by ldomaradzki on 27.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrainScheduleViewController : UIViewController <UIWebViewDelegate>
{
    UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURL *url;

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end
