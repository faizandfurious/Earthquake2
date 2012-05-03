//
//  ViewController.m
//  Earthquake!
//
//  Created by Faiz Abbasi on 5/2/12.
//  Copyright (c) 2012 Menlo School. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>


@interface ViewController ()



@end

@implementation ViewController

@synthesize earthquakeArray = _earthquakeArray;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize mapView = _mapView;
@synthesize receivedData;


- (NSURL *)bundleDatabaseURL
{
    return [[NSBundle mainBundle] URLForResource:@"Core_Data"
                                   withExtension:@"sqlite"];
}
- (NSURL *)documentDatabaseURL
{
    return [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] 
                                    stringByAppendingPathComponent: @"Core_Data.sqlite"]];
}
- (void)initializeDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *toURL = [self documentDatabaseURL];
    if ([fileManager fileExistsAtPath:[toURL path]]) {
        // must already have copied it
        NSLog(@"Already have the data");
    } else {
        // copy our canned census database out of the resource bundle and into the Document directory
        NSURL *fromURL = [self bundleDatabaseURL];
        NSError *error;
        if ([fileManager copyItemAtURL:fromURL toURL:toURL error:&error]) {
            NSLog(@"Copied twitter data");
        } else {
            NSLog(@"Failed to copy from '%@' to '%@': %@",
                  fromURL,
                  toURL,
                  [error localizedDescription]);
        }
    }
}


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
    for(int i = 0; i < 10; i++)
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

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store         
 coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in    
 application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] 
                                               stringByAppendingPathComponent: @"Core_Data.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should 
         not use this function in a shipping application, although it may be useful during 
         development. If it is not possible to recover from the error, display an alert panel that 
         instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object 
         model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
