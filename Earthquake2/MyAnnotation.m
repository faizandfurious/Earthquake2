//
//  MyAnnotation.m
//  Homework3
//
//  Created by Faiz Abbasi on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
    _title = @"";
    return self;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title 
{
    _coordinate = coordinate;
    _title = title;
    return self;
}

- (void) Title:(NSString *)title
{
    _title = title;
}
@end
