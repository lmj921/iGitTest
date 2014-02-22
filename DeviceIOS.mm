//
//  DeviceIOS.cpp
//  bomb
//
//  Created by 陆 明俊 on 13-8-28.
//  Copyright 2013年 Black Pearl. All rights reserved.
//

#include "DeviceIOS.h"
#include "UIDevice+Hardware.h"

int DeviceIOS::platformType()
{
    return [[UIDevice currentDevice] platformType];
}

UIDeviceFamily DeviceIOS::deviceFamily()
{
    return [[UIDevice currentDevice] deviceFamily];
}

bool DeviceIOS::hasRetinaDisplay()
{
    return [[UIDevice currentDevice] hasRetinaDisplay];
}