//
//  DeviceIOS.h
//  bomb
//
//  Created by 陆 明俊 on 13-8-28.
//  Copyright 2013年 Black Pearl. All rights reserved.
//

#ifndef __bomb__DeviceIOS__
#define __bomb__DeviceIOS__

#include "cocos2d.h"
#include "DeviceConstant.h"

USING_NS_CC;

class DeviceIOS
: public CCObject
{
public:
    static int platformType();
    static bool hasRetinaDisplay();
    static UIDeviceFamily deviceFamily();
};

#endif
