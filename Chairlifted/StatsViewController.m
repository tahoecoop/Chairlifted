//
//  StatsViewController.m
//  Chairlifted
//
//  Created by Bradley Justice on 8/18/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "StatsViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <MapKit/MapKit.h>
#import "Run.h"
#import <AFNetworkReachabilityManager.h>

@interface StatsViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CMAltimeter *myAltimeter;

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property BOOL isRecordingRun;
@property double altitudeDelta;
@property (weak, nonatomic) IBOutlet UILabel *altitudeDeltaLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTraveledLabel;
@property CLLocation *startLocation;
@property CLLocation *endLocation;
@property CLLocationDistance distanceTraveled;
@property NSMutableArray *speedsArray;
@property double topSpeed;
@property double avgSpeed;
@property (weak, nonatomic) IBOutlet UILabel *topSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel;
@property float timeElapsed;
@property NSDate *timeCreated;
@property NSDate *timeEnded;

@end


@implementation StatsViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.timeElapsed = 0;
    self.speedsArray = [NSMutableArray new];
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
//    self.distanceTraveledLabel.text = [NSString stringWithFormat:@"%f meters",self.distanceTraveled];
//    self.altitudeDeltaLabel.text = [NSString stringWithFormat:@"%f meters",self.altitudeDelta];
//    self.topSpeedLabel.text = [NSString stringWithFormat:@"%f m/s", self.topSpeed];
//    self.avgSpeedLabel.text = [NSString stringWithFormat:@"%f m/s", self.avgSpeed];
//    self.timeElapsedLabel.text = [NSString stringWithFormat:@"%f seconds",self.timeElapsed];

    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
}

-(void)showDataOnLabels
{
    self.timeElapsedLabel.text = [NSString stringWithFormat:@"%f seconds",self.timeElapsed];
    self.distanceTraveledLabel.text = [NSString stringWithFormat:@"%f meters",self.distanceTraveled];
    self.altitudeDeltaLabel.text = [NSString stringWithFormat:@"%f meters",self.altitudeDelta];
    self.topSpeedLabel.text = [NSString stringWithFormat:@"%f m/s", self.topSpeed];
    self.avgSpeedLabel.text = [NSString stringWithFormat:@"%f m/s", self.avgSpeed];
}


- (IBAction)onStartStopPressed:(UIButton *)sender {

    if ([CMAltimeter isRelativeAltitudeAvailable]) {

        self.myAltimeter = [[CMAltimeter alloc]init];

        if (self.isRecordingRun == NO) {
            self.timeCreated = [NSDate new];
            [self.locationManager startUpdatingLocation];
            self.isRecordingRun = YES;
            [self.onOffButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.timeElapsed = 0;

            NSOperationQueue *operationsQueue = [NSOperationQueue mainQueue];
            [self.myAltimeter startRelativeAltitudeUpdatesToQueue:operationsQueue withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
                self.altitudeDelta = -[altitudeData.relativeAltitude doubleValue];
            }];

        } else {

            self.isRecordingRun = NO;
            self.timeEnded = [NSDate new];
            [self.onOffButton setTitle:@"Start" forState:UIControlStateNormal];
            self.altitudeDeltaLabel.text = [NSString stringWithFormat:@"%f",self.altitudeDelta];
            [self.myAltimeter stopRelativeAltitudeUpdates];
            [self saveInfo];
            [self.locationManager stopUpdatingLocation];
        }
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self showDataOnLabels];

    for (CLLocation *location in locations) {
        NSNumber *speed = [[NSNumber alloc]initWithDouble:location.speed];
        [self.speedsArray addObject:speed];
    }
    self.startLocation = locations.firstObject;
    self.endLocation = locations.lastObject;
}


-(void)saveInfo {
    self.distanceTraveled = [self.startLocation distanceFromLocation:self.endLocation];
    double sum = 0;
    for (NSNumber *speed in self.speedsArray) {
        sum += fabs([speed doubleValue]);
    }
    self.avgSpeed = sum / self.speedsArray.count;
    self.topSpeed = [[self.speedsArray valueForKeyPath:@"@max.self"]doubleValue];

    NSTimeInterval time = self.timeEnded.timeIntervalSince1970-self.timeCreated.timeIntervalSince1970;
    self.timeElapsed = time;

    Run *run = [Run new];
    run.topSpeed = self.topSpeed;
    run.avgSpeed = self.avgSpeed;
    run.relativeAltitude = self.altitudeDelta;
    run.timeOfRun = self.timeElapsed;
    run.speed = self.speedsArray;
    run.distanceTraveled = self.distanceTraveled;

    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        [run saveInBackground];

    } else {
        [run saveEventually];

        UIAlertController *offlineAlert = [UIAlertController alertControllerWithTitle:@"Offline" message:@"You have submitted a run offline. This run will be saved locally for now. Next time you open Chairlifted with Internet, it will automatically be saved." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [offlineAlert addAction:dismiss];
        [self presentViewController:offlineAlert animated:YES completion:nil];
    }
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
}









@end