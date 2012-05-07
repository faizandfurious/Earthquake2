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
    NSDictionary *dictSecond = [receivedData lastObject];
    id year_val2 = [dictSecond objectForKey:@"Year"];
    int year2 = [year_val2 intValue];
    NSString *strYear = [NSString stringWithFormat:@"%i", year2];
    NSString *theYear = @"The Year is ";
    NSMutableString *finalString = [NSMutableString stringWithString:theYear];
    [finalString appendString:strYear];
    yearLabel.text = finalString;
    
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


- (void)viewDidUnload
{
    [self setMapView:nil];
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
    int value = (self.counter/receivedData.count)*100;
    CGFloat red, green, blue;
    if([overlay isKindOfClass:[HeatMap class]]){
        return [[HeatMapView alloc] initWithOverlay:overlay];
    }
    else{
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:overlay];
        //Set the color based on when the earthquake occurred.
        if(self.counter <= 0) { 
            circleView.fillColor = [UIColor greenColor];
            circleView.strokeColor = [UIColor greenColor];
            circleView.alpha = 0.2;
            circleView.lineWidth = 2;
        } else if(self.counter < receivedData.count*.2) {
            red = green = 0;
            blue = 4 * (value + 0.125);
        } else if(self.counter < receivedData.count*.4) {
            red = 0;
            green = 4 * (value - 0.125);
            blue = 1;
        } else if(self.counter < receivedData.count*.6) {
            red = 4 * (value - 0.375);
            green = 1;
            blue = 1 - 4 * (value - 1600);
        } else if(self.counter < receivedData.count*.8) {
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

//This method reads the data from a csv file and makes it available to the application.
-(NSMutableArray *) readFileWithContent:(NSString *)content{
    
    NSMutableArray *result = [NSMutableArray array];
    //The CSV file ends with PDE, which is unncessary and thus is the delimiter for each row.
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
                //Looks for commas to separate columns
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
    
    //Pulls the data, then populates the heatmap with the latitudes and longitudes.
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

//This method allows the user to see a visualization of the earthquakes, based on time
- (void) drawAnimatedCircles {
    NSLog(@"%i", self.counter);

    [_mapView removeOverlays:circles];

    if(self.counter < receivedData.count)
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
        //Continually calls this method until it reaches the final row.
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(drawAnimatedCircles) userInfo:nil repeats:NO];
    }
    
}

- (IBAction)animateEarthquakesButtonOnTouchDown:(id)sender {
    self.counter = 0;
    [self drawAnimatedCircles];
}

@end
