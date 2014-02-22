//
//  bombAppController.h
//  bomb
//
//  Created by 陆 明俊 on 13-4-1.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//
#import "WXApi.h"

@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate,UIApplicationDelegate,WXApiDelegate> {
    UIWindow *window;
    RootViewController    *viewController;
    int aa;
    int bb;
    int cc;
    int dd;
    
    int ee;
    
    bool haha;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

@end

