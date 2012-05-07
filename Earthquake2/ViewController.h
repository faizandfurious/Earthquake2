//
//  ViewController.h
//  Earthquake!
//
//  Created by Faiz Abbasi on 5/2/12.
//  Copyright (c) 2012 Menlo School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
#import "HeatMap.h"
#import "HeatMapView.h"


@interface ViewController : UIViewController <MKMapViewDelegate>{
    
    NSMutableArray *_allEntries;
    CGColorRef *colors;
    
}

@property (retain) NSMutableArray *allEntries;
@property (strong, nonatomic) NSMutableArray *receivedData;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL heatMapBoolean;
@property (strong, nonatomic) HeatMap *hm;
@property (nonatomic) BOOL changedboolean;



- (void)drawCircles;
- (IBAction)heatMapValueChanged:(id)sender;


@end
