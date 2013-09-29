//
//  StationAnnotationView.m
//  Lokomapa
//
//  Created by ldomaradzki on 29.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import "StationAnnotationView.h"

@implementation StationAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canShowCallout = YES;
        self.multipleTouchEnabled = NO;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"StationPin"];
    }
    return self;
}

@end
