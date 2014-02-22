//
//  Motion.m
//  bomb
//
//  Created by Shadow on 13-7-14.
//  Copyright 2013年 Black Pearl. All rights reserved.
//

#import "Motion.h"
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>

static CMMotionManager *m_motionManager=NULL;

Motion::~Motion()
{
    m_motionManager=NULL;
}

bool Motion::init() {
    _roll = 0;
    _yaw = 0;
    _pitch = 0;
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval =1.0/60.0;
    if (motionManager.isDeviceMotionAvailable) {
        [motionManager startDeviceMotionUpdates];
    }
    m_motionManager = motionManager;
    this->schedule(schedule_selector(Motion::update));
    return true;
}

void Motion::update()
{
    CMMotionManager* temMotion=(CMMotionManager*) m_motionManager;
    
    CMDeviceMotion *currentDeviceMotion = temMotion.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    _yaw = roundf((float)(CC_RADIANS_TO_DEGREES(currentAttitude.yaw)));
    _roll = roundf((float)(CC_RADIANS_TO_DEGREES(currentAttitude.roll)));
    _pitch = roundf((float)(CC_RADIANS_TO_DEGREES(currentAttitude.pitch)));
}

