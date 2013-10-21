//
//  ZoomIndicatorView.h
//  Lokomapa
//
//  Created by ldomaradzki on 21.10.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomIndicatorView : UIView

@property (nonatomic, weak) IBOutlet UIView *errorLabel;

-(void)show;
-(void)updateZoomLevel:(double)level;
-(void)hide;

@end
