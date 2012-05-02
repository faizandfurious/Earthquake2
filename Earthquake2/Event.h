//
//  Event.h
//  Earthquake2
//
//  Created by Faiz Abbasi on 5/2/12.
//  Copyright (c) 2012 Menlo School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * magnitude;
@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSString * catalog;

@end
