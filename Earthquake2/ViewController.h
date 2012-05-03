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
    
}

@property (retain) NSMutableArray *allEntries;
@property (strong, nonatomic) NSMutableArray *receivedData;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *timeFrame;
@property (nonatomic) BOOL heatMapBoolean;
@property (nonatomic) BOOL mkCircleBoolean;
@property (strong, nonatomic) HeatMap *hm;
@property (strong, nonatomic) NSMutableArray *circles;
@property (strong, nonatomic) NSMutableArray *annotations;

- (void)drawCircle;
- (IBAction)heatMapValueChanged:(id)sender;
- (IBAction)mkCircleValueChanged:(id)sender;


@end
