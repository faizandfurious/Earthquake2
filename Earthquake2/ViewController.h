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


@interface ViewController : UIViewController <MKMapViewDelegate>{
    
    NSMutableArray *earthquakeArray;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;       
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
}

@property (retain, nonatomic) NSMutableArray *earthquakeArray;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSMutableArray *receivedData;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void)drawCircle;
- (NSString *)applicationDocumentsDirectory;

@end
