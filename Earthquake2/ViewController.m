//
//  ViewController.m
//  Earthquake!
//
//  Created by Faiz Abbasi on 5/2/12.
//  Copyright (c) 2012 Menlo School. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@property NSMutableArray *circles;

@end

@implementation ViewController

@synthesize allEntries = _allEntries;
@synthesize mapView = _mapView;
@synthesize receivedData;
@synthesize heatMapBoolean;
@synthesize hm;
@synthesize changedboolean;
@synthesize circles;


- (void)viewDidLoad
{
    self.mapView.delegate = self;
    [super viewDidLoad];
    circles = [[NSMutableArray alloc] init];
    
    NSString *pathname = [[NSBundle mainBundle] pathForResource:@"sigeqdata3"
                                                         ofType:@"csv"];
    
    NSString* content = [NSString stringWithContentsOfFile:pathname
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    receivedData = [self readFileWithContent:content];
    [self drawCircles];
    
    hm = [[HeatMap alloc] initWithData:[self heatMapData]];
    [self.mapView addOverlay:hm];
    [self.mapView setVisibleMapRect:[hm boundingMapRect] animated:YES];
    
    

	// Do any additional setup after loading the view, typically from a nib.
}


- (void)drawCircles{
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

            MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:mag*50000];
            [circles addObject:circle];

            
        }
    
    [_mapView addOverlays:circles];
}

- (IBAction)heatMapValueChanged:(id)sender {
    
    heatMapBoolean = !heatMapBoolean;
    
    if(!heatMapBoolean)
    {
        [self.mapView addOverlay:hm];
        [self.mapView setVisibleMapRect:[hm boundingMapRect] animated:YES];
    }
    else{
        [self.mapView removeOverlay:hm];
    }
    
}

- (IBAction)mkCircleValueChanged:(id)sender {
}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//implement the viewForOverlay delegate method...    
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay 
{
    if([overlay isKindOfClass:[HeatMap class]]){
        return [[HeatMapView alloc] initWithOverlay:overlay];
    }
    else{
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];

        circleView.fillColor = [UIColor redColor];
        circleView.strokeColor = [UIColor redColor];
        circleView.alpha = 1;
        circleView.alpha = 0.05;
        circleView.lineWidth = 2;
        
        return circleView;
    }
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
- (NSDictionary *)heatMapData
{
    
    
    NSMutableDictionary *toRet = [[NSMutableDictionary alloc] initWithCapacity:[receivedData count]];
    for(int i = 0; i < receivedData.count; i++)
    {
        NSDictionary *dict = [receivedData objectAtIndex:i];
        id lat_val = [dict objectForKey:@"Latitude"];
        id lon_val = [dict objectForKey:@"Longitude"];
        float lat = [lat_val floatValue];
        float lon = [lon_val floatValue];
    
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
        NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
        [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
    }
    
    
    return toRet;
}

@end
