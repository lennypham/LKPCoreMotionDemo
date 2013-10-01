//
//  ViewController.m
//  LKPCoreMotionDemo
//
//  Created by Leonard Pham on 10/1/13.
//  Copyright (c) 2013 Lenny Pham. All rights reserved.
//

#import "ViewController.h"

#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property (nonatomic) CMMotionActivityManager *myActivityManager;

@property (nonatomic) CMStepCounter *myStepCounter;

@property (nonatomic) NSOperationQueue *myOperationQueue;

@property (weak, nonatomic) IBOutlet UILabel *currentUserActivityLabel;

@property (weak, nonatomic) IBOutlet UILabel *activityConfidenceLabel;

@property (weak, nonatomic) IBOutlet UILabel *activityUpdateCounterLabel;

@property (nonatomic) NSUInteger updateCounter;

@property (weak, nonatomic) IBOutlet UILabel *totalStepsLabel;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.myActivityManager = [[CMMotionActivityManager alloc] init];
        
        self.myOperationQueue = [[NSOperationQueue alloc] init];
        
        self.myStepCounter = [[CMStepCounter alloc] init];
        
        self.myOperationQueue.name = @"MyOpQueue";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // NOTE: I can't find a low-level function to programatically check for and/or request
    // access to the motion sensor.
    if ([CMMotionActivityManager isActivityAvailable] && [CMStepCounter isStepCountingAvailable])
    {
        [self.myActivityManager startActivityUpdatesToQueue:self.myOperationQueue
                                                withHandler:^(CMMotionActivity *activity) {
                                                    [self performSelectorOnMainThread:@selector(respondToUserActivity:)
                                                                           withObject:activity
                                                                        waitUntilDone:NO];
                                                }];
        
        [self.myStepCounter startStepCountingUpdatesToQueue:self.myOperationQueue
                                                   updateOn:1
                                                withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                                    [self performSelectorOnMainThread:@selector(respondToUserSteps:)
                                                                           withObject:[NSNumber numberWithInteger:numberOfSteps]
                                                                        waitUntilDone:NO];
                                                }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.myActivityManager  stopActivityUpdates];
    
    [self.myStepCounter stopStepCountingUpdates];
    
    [self.myOperationQueue cancelAllOperations];
}

- (void)respondToUserSteps:(NSNumber *)numberOfSteps
{
    self.totalStepsLabel.text = [NSString stringWithFormat:@"%li",(long)[numberOfSteps integerValue]];
}

- (void)respondToUserActivity:(CMMotionActivity *)anActivity
{
    self.updateCounter++;
    
    NSString *currentActivityString;
    
    if (anActivity.stationary)
    {
        currentActivityString = @"STATIONARY";
    }
    else if (anActivity.walking)
    {
        currentActivityString = @"WALKING";
    }
    else if (anActivity.running)
    {
        currentActivityString = @"RUNNING";
    }
    else if (anActivity.automotive)
    {
        currentActivityString = @"DRIVING A CAR";
    }
    else
    {
        currentActivityString = @"UNKOWN";
    }
    
    NSString *confidenceLabel;
    
    switch (anActivity.confidence) {
            
        case CMMotionActivityConfidenceLow:
        {
            confidenceLabel = @"LOW";
            break;
        }
        case CMMotionActivityConfidenceMedium:
        {
            confidenceLabel = @"MEDIUM";
            break;
        }
        case CMMotionActivityConfidenceHigh:
        {
            confidenceLabel = @"HIGH";
            break;
        }
            
        default:
            break;
    }
    
    self.activityConfidenceLabel.text    = confidenceLabel;
    self.currentUserActivityLabel.text   = currentActivityString;
    self.activityUpdateCounterLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.updateCounter];
}

@end
