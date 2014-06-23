//
//  TrainScheduleViewController.m
//  Lokomapa
//
//  Created by ldomaradzki on 27.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "TrainScheduleViewController.h"

@implementation TrainScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Schedule", nil);
    
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://rozklad.sitkol.pl/bin/traininfo.exe/%@/%@?date=%@&pageViewMode=PRINT", [self getSitkolLanguageExtension], self.trainId, [[NSDate date] getDefaultDateString]]];

    // dirty browser hack
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": @"Mozilla"}];

    self.request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:self.request];
}

-(NSString*)getSitkolLanguageExtension {
    NSString *currentLocale = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"][0];
    
    NSString *sitkolLanguageExtension = @"en"; //default language
    
    if ([currentLocale isEqualToString:@"pl"]) {
        sitkolLanguageExtension = @"pn";
    }
    
    if ([currentLocale isEqualToString:@"ru"]) {
        sitkolLanguageExtension = @"rn";
    }
    
    if ([currentLocale isEqualToString:@"de"]) {
        sitkolLanguageExtension = @"dn";
    }
    
    return sitkolLanguageExtension;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL isEqual:self.request.URL])
        return YES;
    
    return NO;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSArray *iPhonePrettyAttributes =
  @[
    @"document.getElementsByClassName(\"hafasResult\")[1].setAttribute(\"style\",\"width:400px\");",
    @"document.getElementsByClassName('hafasButtons')[0].style.display = 'none';",
    @"document.getElementById('cookieInfo').style.display = 'none';"    
    ];
    
    for (NSString *prettyAttributes in iPhonePrettyAttributes) {
        [webView stringByEvaluatingJavaScriptFromString:prettyAttributes];
    }
    
    [indicatorView stopAnimating];
}


@end
