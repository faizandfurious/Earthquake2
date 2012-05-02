//
//  ViewController.m
//  Earthquake!
//
//  Created by Faiz Abbasi on 5/2/12.
//  Copyright (c) 2012 Menlo School. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()



@end

@implementation ViewController

@synthesize allEntries = _allEntries;
@synthesize mapView = _mapView;
@synthesize receivedData;


- (void)viewDidLoad
{
    self.mapView.delegate = self;
    [super viewDidLoad];
    
    NSString *pathname = [[NSBundle mainBundle] pathForResource:@"eqdata"
                                                         ofType:@"csv"];
    
    NSString* content = [NSString stringWithContentsOfFile:pathname
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    receivedData = [self readFileWithContent:content];
    [self drawCircle];
    

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)drawCircle{
    NSMutableArray *circles = [[NSMutableArray alloc] init];
    for(int i = 0; i < receivedData.count; i++)
    {
        NSDictionary *dict = [receivedData objectAtIndex:i];
        id lat_val = [dict objectForKey:@"Latitude"];
        id lon_val = [dict objectForKey:@"Longitude"];
        id mag_val = [dict objectForKey:@"Magnitude"];
        float lat = [lat_val floatValue];
        float lon = [lon_val floatValue];
        float mag = [mag_val floatValue];
        

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
//        NSLog(@" Coordinates: (%f, %f), Magnitude: %f", coordinate.latitude, coordinate.longitude, mag);
//        MyAnnotation *annotation = [[MyAnnotation alloc] initWithCoordinate:coordinate];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:mag*50000];
        [circles addObject:circle];

       

//        [self.mapView addAnnotation:annotation];
        
    }
    
//    NSArray *staticCircles = [NSArray arrayWithArray:circles];
    [_mapView addOverlays:circles];

}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//implement the viewForOverlay delegate method...    
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay 
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [UIColor redColor];
    circleView.alpha = 0.25;
    circleView.lineWidth = 2;
    return circleView;
}

-(NSMutableArray *) readFileWithContent:(NSString *)content{
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [content componentsSeparatedByString:@",PDE"];
    NSEnumerator *theEnum = [lines objectEnumerator];
    NSArray *keys = nil;
    int keyCount = 0;
    NSString *theLine;
    
    while(nil !=(theLine = [theEnum nextObject]) )
    {
        if(![theLine isEqualToString:@""] && ![theLine hasPrefix:@"#"])
        {
            if(nil == keys)
            {
                keys = [theLine componentsSeparatedByString:@","];
                keyCount = [keys count];
                
            }
            else {
                NSMutableDictionary *lineDict = [NSMutableDictionary dictionary];
                NSArray *values = [theLine componentsSeparatedByString:@","];
                int valueCount = [values count];
                int i;
                
                for(i = 0; i < keyCount && i < valueCount; i++)
                {
                    NSString *value = [values objectAtIndex:i];
                    if (nil != value && ![value isEqualToString:@""]) {
                        [lineDict setObject:value forKey:[keys objectAtIndex:i]];
                    }
                }
                if ([lineDict count])
                {
                    [result addObject:lineDict];
                }
            }
        }
    }
    return result;
    
}
@end
