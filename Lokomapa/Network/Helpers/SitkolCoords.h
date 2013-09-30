//
//  SitkolCoords.h
//  Lokomapa
//
//  Created by ldomaradzki on 30.09.2013.
//  Copyright (c) 2013 ldomaradzki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SitkolCoords : NSObject

@property (nonatomic, copy) NSString *xCoord, *yCoord;

- (id)initWithXCoord:(NSString*)xCoord andYCoord:(NSString*)yCoord;

+(SitkolCoords*)getUpperLeftCornerFromRegion:(MKCoordinateRegion)region;
+(SitkolCoords*)getBottomRightCornerFromRegion:(MKCoordinateRegion)region;
@end
