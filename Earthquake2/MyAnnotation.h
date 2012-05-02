//
//  MyAnnotation.h
//  Homework3
//
//  Created by Faiz Abbasi on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

// add an init method so you can set the coordinate property on startup
- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate 
                 andTitle:(NSString *)title;
- (void) Title:(NSString *)title;
@end
