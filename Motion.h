//
//  Motion.h
//  bomb
//
//  Created by Shadow on 13-7-14.
//  Copyright 2013年 Black Pearl. All rights reserved.
//

#ifndef __bomb__Motion__
#define __bomb__Motion__

#include "cocos2d.h"

using namespace std;
USING_NS_CC;

class Motion
: public CCNode
{
private:
    
public:
    ~Motion();
    bool init();
    CREATE_FUNC(Motion);
    
    // logic
    void update();
    
    CC_SYNTHESIZE(float, _yaw, Yaw);
    CC_SYNTHESIZE(float, _roll, Roll);
    CC_SYNTHESIZE(float, _pitch, Pitch);
};

#endif


