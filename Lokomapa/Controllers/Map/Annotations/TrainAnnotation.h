//
//  TrainAnnotation.h
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Train.h"

@interface TrainAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) Train *train;

@end
