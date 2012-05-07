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
@property int counter;

@end

@implementation ViewController

@synthesize allEntries = _allEntries;
@synthesize mapView = _mapView;
@synthesize receivedData;
@synthesize heatMapBoolean;
@synthesize hm;
@synthesize changedboolean;
@synthesize timeSlider;
@synthesize circles;
@synthesize timer;
@synthesize animateEarthquakesButton;
@synthesize yearLabel;
@synthesize counter;


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
    NSDictionary *dictFirst = [receivedData objectAtIndex:0];
    id year_val1 = [dictFirst objectForKey:@"Year"];
    int year1 = [year_val1 intValue];
    timeSlider.minimumValue = year1;
    timeSlider.maximumValue = 2013;
    yearLabel.text = @"The Year is 2012.";
    
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
            id year_val = [dict objectForKey:@"Year"];
            float lat = [lat_val floatValue];
            float lon = [lon_val floatValue];
            float mag = [mag_val floatValue];
            int year = [year_val intValue];
            NSString *strYear = [NSString stringWithFormat:@"%i", year];

            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);

            MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:mag*50000];
            circle.title = strYear;
            [circles addObject:circle];

            
        }
    
    [_mapView addOverlays:circles];
}

- (void)drawCircleWithMaximumTime:(int)maxYear{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    circles.removeAllObjects;
    
    for(int i = 0; i < receivedData.count; i++)
    {
        NSDictionary *dict = [receivedData objectAtIndex:i];
        id lat_val = [dict objectForKey:@"Latitude"];
        id lon_val = [dict objectForKey:@"Longitude"];
        id mag_val = [dict objectForKey:@"Magnitude"];
        id year_val = [dict objectForKey:@"Year"];
        id id_val = [dict objectForKey:@"id"];
        float lat = [lat_val floatValue];
        float lon = [lon_val floatValue];
        float mag = [mag_val floatValue];
        float year = [year_val floatValue];
        int eid = [id_val intValue];
        if( year < maxYear)
        {
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
            NSString *strMag = [NSString stringWithFormat:@"%f", mag];
            
            MyAnnotation *annotation = [[MyAnnotation alloc] initWithCoordinate:coordinate 
                                                                       andTitle:(strMag)];
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:mag*50000];
            [circles addObject:circle];
            [annotations addObject:annotation];
        }
        
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

- (IBAction)timeSliderValueChanged:(id)sender {
    
    [_mapView removeOverlays:circles];
    [self drawCircleWithMaximumTime:self.timeSlider.value];
    
}



- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setTimeSlider:nil];
    [self setAnimateEarthquakesButton:nil];
    [self setYearLabel:nil];
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
    int value = (self.counter/1987)*100;
    CGFloat red, green, blue;
    if([overlay isKindOfClass:[HeatMap class]]){
        return [[HeatMapView alloc] initWithOverlay:overlay];
    }
    else{
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
        
        if(self.counter <= 0) { 
            red = green = blue = 0;
        } else if(self.counter < 400) {
            red = green = 0;
            blue = 4 * (value + 0.125);
        } else if(self.counter < 800) {
            red = 0;
            green = 4 * (value - 0.125);
            blue = 1;
        } else if(self.counter < 1200) {
            red = 4 * (value - 0.375);
            green = 1;
            blue = 1 - 4 * (value - 1600);
        } else if(self.counter < 0.875) {
            red = 1;
            green = 1 - 4 * (value - 0.625);
            blue = 0;
        } else {
            red = MAX(1 - 4 * (value - 0.875), 0.5);
            green = blue = 0;
        }
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        circleView.fillColor = color;
        circleView.strokeColor = color;
        circleView.alpha = 0.2;
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

- (void) drawAnimatedCircles {
    NSLog(@"%i", self.counter);
    if(self.counter == 0)
    {
        [_mapView removeOverlays:circles];
    }
    if(self.counter < 1987)
    {
        NSDictionary *dict = [receivedData objectAtIndex:self.counter];
        id lat_val = [dict objectForKey:@"Latitude"];
        id lon_val = [dict objectForKey:@"Longitude"];
        id mag_val = [dict objectForKey:@"Magnitude"];
        id year_val = [dict objectForKey:@"Year"];
        float lat = [lat_val floatValue];
        float lon = [lon_val floatValue];
        float mag = [mag_val floatValue];
        int year = [year_val intValue];
        NSString *strYear = [NSString stringWithFormat:@"%i", year];
        NSString *theYear = @"The Year is ";
        NSMutableString *finalString = [NSMutableString stringWithString:theYear];
        [finalString appendString:strYear];
        yearLabel.text = finalString;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:mag*50000];
        circle.title = strYear;
        [_mapView addOverlay:circle];
        
        self.counter++;
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(drawAnimatedCircles) userInfo:nil repeats:NO];
    }
    
}

- (IBAction)animateEarthquakesButtonOnTouchDown:(id)sender {
    self.counter = 0;
    [self drawAnimatedCircles];
}

@end
