//
//  ObjectiveCViewController.m
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 14.06.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

#import "ObjectiveCViewController.h"
@import IndoorNavi;

NSString* const FrontendTargetHost = @"http://172.16.170.53:4200";
NSString* const BackendTargetHost = @"http://172.16.170.53:90";
NSString* const ApiKey = @"TestAdmin";

@interface ObjectiveCViewController ()
{
    __weak IBOutlet INMap *map;
    INMarker* marker;
    INInfoWindow* infoWindow;
    INPoint points1[10];
    INPoint points2[10];
}
@end

@implementation ObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializePoints];
    [map setupConnectionWithTargetHost:FrontendTargetHost andApiKey:ApiKey];
    [self.view addSubview:map];
}

- (void)initializePoints {
    for (int i = 0; i < 10; i++) {
        INPoint point1 = INPointMake(arc4random_uniform(3000), arc4random_uniform(3000));
        INPoint point2 = INPointMake(arc4random_uniform(3000), arc4random_uniform(3000));
        points1[i] = point1;
        points2[i] = point2;
    }
}

- (void)showAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ALERT!"
                                                                   message:@"Marker touched!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)drawInfoWindow:(id)sender {
    [self placeMarker:sender];
    infoWindow.height = arc4random_uniform(220) + 30;
    infoWindow.width = arc4random_uniform(220) + 30;
    [marker addInfoWindow:infoWindow];
}

- (IBAction)drawPolyline1:(id)sender {
    INPolyline* polyline = [[INPolyline alloc] initWithMap:map];
    [polyline setPointsArray:points1 withArraySize:10];
    [polyline setColorWithRed:1.0 green:0.5 blue:0.5];
    [polyline draw];
}

- (IBAction)drawPolyline2:(id)sender {
    INPolyline* polyline = [[INPolyline alloc] initWithMap:map];
    [polyline setPointsArray:points2 withArraySize:10];
    [polyline setColorWithRed:0.8 green:0.4 blue:0.2];
    [polyline draw];
}

- (IBAction)drawArea:(id)sender {
    INArea* area = [[INArea alloc] initWithMap:map];
    [area setPointsArray:points1 withArraySize:10];
    [area setFillColorWithRed:0.8 green:0.4 blue:0.2];
    [area setOpacity:0.5];
    [area draw];
}

- (IBAction)placeMarker:(id)sender {
    marker = [[INMarker alloc] initWithMap:map];
    [marker setPoint:INPointMake(600, 600)];
    [marker setIconWithPath:@"https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png"];
    [marker setLabelWithText:@"Tekst ABCD"];
    __weak ObjectiveCViewController *weakSelf = self;
    [marker addEventListenerOnClickCallback:^{
        [weakSelf showAlert];
    }];
    [marker draw];
}

- (IBAction)createReport:(id)sender {
    INReport* report = [[INReport alloc] initWithMap:map targetHost:BackendTargetHost apiKey:ApiKey];
    NSDate* from = [[NSDate alloc] initWithTimeIntervalSince1970:1428105600];
    NSDate* to = [NSDate new];
    [report getAreaEventsFromFloorWithID:2 from:from to:to callbackHandler:^(NSArray<AreaEvent*>* areaEvents) {
        NSLog(@"Area events:");
        for (AreaEvent* areaEvent in areaEvents) {
            NSLog(@" - Tag ID: %ld", (long)areaEvent.tagID);
            NSLog(@" - Area ID: %ld", (long)areaEvent.areaID);
            NSLog(@" - Date: %@", areaEvent.date);
            NSLog(@" - Name: %@", areaEvent.areaName);
            NSLog(@" - Mode: %ld", (long)areaEvent.mode);
        }
    }];
    [report getCoordinatesFromFloorWithID:2 from:from to:to callbackHandler:^(NSArray<Coordinates*>* coordinatesArray) {
        NSLog(@"Coordinates:");
        for (Coordinates* coordinates in coordinatesArray) {
            NSLog(@" - X: %ld", (long)coordinates.x);
            NSLog(@" - Y: %ld", (long)coordinates.y);
            NSLog(@" - Tag ID: %ld", (long)coordinates.tagID);
            NSLog(@" - Date: %@", coordinates.date);
        }
    }];
}

- (IBAction)getCoordinates:(id)sender {
    NSLog(@"InfoWindow id: %@",infoWindow.objectID);
    [infoWindow getPointsWithCallbackHandler:^(const INPoint points[], NSInteger size) {
        NSLog(@"InfoWindow's coordinates:");
        for (int i = 0; i < size; i++) {
            NSLog(@"Coordinate: (%d,%d)", points[i].x, points[i].y);
        }
    }];
}

- (IBAction)drawPolies:(id)sender {
    NSMutableArray<INPolyline*>* polylines = [NSMutableArray<INPolyline*> new];
    for (int i = 0; i < 100; i++) {
        INPolyline* polyline = [[INPolyline alloc] initWithMap:map];
        
        INPoint points[10];
        for (int i = 0; i < 10; i++) {
            points[i] = INPointMake(arc4random_uniform(2000) + 5, arc4random_uniform(2000) + 5);
        }
        
        CGFloat randomRed = (CGFloat)arc4random() / (CGFloat)UINT32_MAX;
        CGFloat randomGreen = (CGFloat)arc4random() / (CGFloat)UINT32_MAX;
        CGFloat randomBlue = (CGFloat)arc4random() / (CGFloat)UINT32_MAX;
        
        [polyline setPointsArray:points withArraySize:10];
        [polyline setColorWithRed:randomRed green:randomGreen blue:randomBlue];
        [polyline draw];
        [polylines addObject:polyline];
        usleep(10000);
    }
}

- (IBAction)load:(id)sender {
    [map load:2 onCompletion:^{
        self->infoWindow = [[INInfoWindow alloc] initWithMap:self->map];
        [self->infoWindow setInnerHTMLWithString:@"<h2>Lorem ipsum dolor sit amet</h2>"];
        NSLog(@"Completed");
    }];
    
    [map addLongClickListenerOnLongClickCallback:^(INPoint point){
        INMarker* marker = [[INMarker alloc] initWithMap:self->map];
        [marker setIconWithPath:@"https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png"];
        INPoint pointWithRealCoordinates = [MapHelper realCoordinatesFromPixel:point scale:self->map.scale];
        [marker setPoint:pointWithRealCoordinates];
        [marker draw];
    }];
    
    [map toggleTagVisibilityWithID:10999];
}

@end
