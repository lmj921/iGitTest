//
//  bombAppController.mm
//  bomb
//
//  Created by 陆 明俊 on 13-4-1.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppController.h"
#import "cocos2d.h"
#import "EAGLView.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#include "MainGameModel.h"
#include "DeviceModel.h"
#include "GlobalDef.h"
#import "DeviceIOS.h"
#include "AnnounceBox.h"
#import "UIDevice+IdentifierAddition.h"
#include "ConfigDataModel.h"

#if defined(VERSION_TW) || defined(VERSION_JP)
#import <FacebookSDK/FacebookSDK.h>
#else
#import "WeiboDelegate.h"
#import "TCWBEngine.h"
#import "TCWeiBoDelegate.h"
#import "WeiboSDK.h"
#endif

#if defined(VERSION_IDS) || defined(VERSION_IDS_SAN)
#import <IDS/IDSHeader.h>
#import "SDKIds.h"
#endif

#if defined(VERSION_YW_PP)
#import <PPAppPlatformKit/PPAppPlatformKit.h>
#endif

#if defined(VERSION_91)
#import "SDK91obsever.h"
#endif

#ifdef VERSION_ZQYJ
#import "SDKOurplam.h"
#endif

#ifdef VERSION_JP
#import <KunlunFB_v1.2.3.31/KLPlatformKit.h>
#import <Partytrack/Partytrack.h>
#endif

@implementation AppController

@synthesize window;
@synthesize viewController;

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    EAGLView *__glView = [EAGLView viewWithFrame: [window bounds]
                                     pixelFormat: kEAGLColorFormatRGBA8
                                     depthFormat: GL_DEPTH_COMPONENT16
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples:0 ];
    
    // Use RootViewController manage EAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = __glView;
    
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    
    [window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    
    //设置屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    //根据设备判断
    DeviceModel::sharedDeviceModel()->setIsHighFps(true);
    int deviceFamily=DeviceIOS::deviceFamily();
    int platformType=DeviceIOS::platformType();
    if (deviceFamily==UIDeviceFamilyiPhone) {
        if (platformType<=UIDevice4iPhone) {//iphone4及以下40fps
            DeviceModel::sharedDeviceModel()->setIsHighFps(false);
        }
    }else if (deviceFamily==UIDeviceFamilyiPad) {
        //ipad 左右边框
        UIImage *rightImg=[UIImage imageNamed:@"ipadzuoyoudi.png"];
        UIImage *leftImg = [UIImage imageWithCGImage:rightImg.CGImage
                                               scale:1.0 orientation: UIImageOrientationUpMirrored];
        UIImageView *leftImage1=[[UIImageView alloc] initWithImage:leftImg];
        leftImage1.frame=CGRectMake(0, 0, 43, 512);
        [viewController.view addSubview:leftImage1];
        
        UIImageView *leftImage2=[[UIImageView alloc] initWithImage:leftImg];
        leftImage2.frame=CGRectMake(0, 512, 43, 512);
        [viewController.view addSubview:leftImage2];
        
        UIImageView *rightImage1=[[UIImageView alloc] initWithImage:rightImg];
        CGRect winFrame=window.frame;
        rightImage1.frame=CGRectMake(winFrame.size.width-43, 0, 43, 512);
        [viewController.view addSubview:rightImage1];
        
        UIImageView *rightImage2=[[UIImageView alloc] initWithImage:rightImg];
        rightImage2.frame=CGRectMake(winFrame.size.width-43, 512, 43, 512);
        [viewController.view addSubview:rightImage2];
        
    }else if (deviceFamily==UIDeviceFamilyiPod) {
        //if (platformType==UIDevice4GiPod) {//ipod都40fps
        DeviceModel::sharedDeviceModel()->setIsHighFps(false);
        //}
    }
    
    //加载text sns
    ConfigDataModel::shareConfigDataModel()->loadTextSNS();
    
    cocos2d::CCApplication::sharedApplication()->run();
    
#if defined(VERSION_91)
    [SDK91obsever sharedSDK91obsever];
#else
    // 通知
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    //重置消息为0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [self localNotification];
#endif
    
    /******云顶开始******/
#if defined(VERSION_IDS)
    [[idsPP sharedInstance] setIsShowAppIcon:NO];
    [[idsPP sharedInstance] setAppIconPostion:IDSAppIconBottomLeft];
    
    //登录登出
    [SDKIds sharedSDKIds];
    
    #if defined(VERSION_IDS_JB)
    //配置appid appkey umengkey 和 启动参数
    [[idsPP sharedInstance] setAppID:3031 AppKey:@"60QFDSid14gpB93HPyELMrKOLDfT76wM" UmengKey:@"521aff4d56240b941100f23c" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:launchOptions];
    #elif defined(VERSION_IDS_UM)
    [[idsPP sharedInstance] setAppID:3042 AppKey:@"62JsWB1l5lhR317B97tzzK4ldkjyIJ3z" UmengKey:@"5294121a56240b69e62b2cf7" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:launchOptions];
    #else
    [[idsPP sharedInstance] setAppID:6001 AppKey:@"l84ba0OP47x526Kh2nJ7sdy0eO3m6ca0" UmengKey:@"5305c49956240b6f9f1b2115" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:launchOptions];
//    [[idsPP sharedInstance] setAppID:4067 AppKey:@"5FUN77tT1G8TODg42g2101GVV192W1UA" UmengKey:@"521afd7a56240b9402012966" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:launchOptions];
    
    //云顶 友盟
//    NSString* appKey=@"d056ca6fd5647bf6413b6d152dddad4c";
//    NSString* deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString* mac = [[UIDevice currentDevice] macaddressPlain];
//    NSString* idfa = [idsPP getAdvertisingIdentifier];
//    NSString* idfv = [[UIDevice currentDevice] idfvString];
//    NSString* urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey,deviceName,mac,idfa,idfv];
//    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
    #endif
    //[[idsPP sharedInstance] hiddenChangeAccountFun];
#endif

#if defined(VERSION_IDS_SAN)
    [[idsPP sharedInstance] setIsShowAppIcon:NO];
    [[idsPP sharedInstance] setAppIconPostion:IDSAppIconBottomLeft];
    
    //登录登出
    [SDKIds sharedSDKIds];
    
    [[idsPP sharedInstance] setAppID:4090 AppKey:@"lE2oq3m9eiN4qN495HGP5g5Tv3bx1rwd" UmengKey:@"52df8a0f56240b740302d5fc" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:launchOptions];
    
    //云顶 友盟
//    NSString* appKey=@"9a1c76c9dec256cb0f515d5711096eee";
//    NSString* deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString* mac = [[UIDevice currentDevice] macaddressPlain];
//    NSString* idfa = [idsPP getAdvertisingIdentifier];
//    NSString* idfv = [[UIDevice currentDevice] idfvString];
//    NSString* urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey,deviceName,mac,idfa,idfv];
//    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
#endif
    /******云顶结束******/
    
#ifdef VERSION_ZQYJ
    SDKOurplam::GetInstance().init(self);
#endif
    
#if defined(VERSION_IDS)
    //新浪微博
    [WeiboSDK registerApp:@"2681384431"];
    
    //微信
    [WXApi registerApp:@"wxea9ad0b91b0edb9a"];
    
    //腾讯微博
    TCWBEngine *engine = [[TCWBEngine alloc] initWithAppKey:WiressSDKDemoAppKey andSecret:WiressSDKDemoAppSecret andRedirectUrl:REDIRECTURI];
    [engine setRootViewController:viewController];
    [[TCWeiBoDelegate sharedWeiboDelegate] setTcwbEngine:engine];
    [engine release];
#elif defined(VERSION_IDS_SAN)
    //新浪微博
    [WeiboSDK registerApp:@"602935686"];
    
    //微信
    [WXApi registerApp:@"wxfc44e93505a45b75"];
    
    //腾讯微博
    TCWBEngine *engine = [[TCWBEngine alloc] initWithAppKey:WiressSDKDemoAppKey andSecret:WiressSDKDemoAppSecret andRedirectUrl:REDIRECTURI];
    [engine setRootViewController:viewController];
    [[TCWeiBoDelegate sharedWeiboDelegate] setTcwbEngine:engine];
    [engine release];
#elif defined(VERSION_YW)
    
    //新浪微博
    [WeiboSDK registerApp:@"602935686"];
    
    //微信
    [WXApi registerApp:@"wxfc44e93505a45b75"];
    
    //腾讯微博
    TCWBEngine *engine = [[TCWBEngine alloc] initWithAppKey:WiressSDKDemoAppKey andSecret:WiressSDKDemoAppSecret andRedirectUrl:REDIRECTURI];
    [engine setRootViewController:viewController];
    [[TCWeiBoDelegate sharedWeiboDelegate] setTcwbEngine:engine];
    [engine release];
#endif
    
#if defined(VERSION_YW_PP)
    [[PPAppPlatformKit sharedInstance] setAppId:1961 AppKey:@"133e3857a6ee7a536c5ec966620d6938"];
    [[PPAppPlatformKit sharedInstance] setIsNSlogData:NO];
    [PPUIKit sharedInstance];
    [PPUIKit setIsDeviceOrientationLandscapeLeft:NO];
    [PPUIKit setIsDeviceOrientationLandscapeRight:NO];
    [PPUIKit setIsDeviceOrientationPortrait:YES];
    [PPUIKit setIsDeviceOrientationPortraitUpsideDown:YES];
#endif
    
#if defined(VERSION_JP)
    [[KLPlatform sharedInstance] registPushNotifyType];
    [[Partytrack sharedInstance] startWithAppID:1385 AndKey:@"184130798d4e95373400c2d2765664a3"];
#endif
    
    [[AnnounceBox sharedAnnounceBox] setRootViewController:viewController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::CCDirector::sharedDirector()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#if defined(VERSION_TW) || defined(VERSION_JP)
    [FBSession.activeSession handleDidBecomeActive];
#endif
    
#if defined(VERSION_IDS)
    #if defined(VERSION_IDS_JB)
    //配置appid appkey umengkey 和 启动参数
    [[idsPP sharedInstance] setAppID:3031 AppKey:@"60QFDSid14gpB93HPyELMrKOLDfT76wM" UmengKey:@"521aff4d56240b941100f23c" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:nil];
    #elif defined(VERSION_IDS_UM)
    [[idsPP sharedInstance] setAppID:3042 AppKey:@"62JsWB1l5lhR317B97tzzK4ldkjyIJ3z" UmengKey:@"5294121a56240b69e62b2cf7" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:nil];
    #else
    [[idsPP sharedInstance] setAppID:6001 AppKey:@"l84ba0OP47x526Kh2nJ7sdy0eO3m6ca0" UmengKey:@"5305c49956240b6f9f1b2115" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:nil];
//    [[idsPP sharedInstance] setAppID:4067 AppKey:@"5FUN77tT1G8TODg42g2101GVV192W1UA" UmengKey:@"521afd7a56240b9402012966" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:nil];
    
    #endif
#endif
    
#if defined(VERSION_IDS_SAN)
    [[idsPP sharedInstance] setAppID:4090 AppKey:@"lE2oq3m9eiN4qN495HGP5g5Tv3bx1rwd" UmengKey:@"52df8a0f56240b740302d5fc" TalkingDataKey:@"" IDSOrientation:IDSInterfaceOrientationPortrait LaunchOptions:nil];
#endif
    
#ifdef VERSION_JP
    [[KLPlatform sharedInstance] resetPushNotify];
#endif
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::CCDirector::sharedDirector()->resume();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::CCApplication::sharedApplication()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::CCApplication::sharedApplication()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - Notification
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token=[[NSString alloc] initWithFormat:@"%@",deviceToken];
    NSString *tempToken=[token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tempToken=[tempToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    tempToken=[tempToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    CCString *temp=new cocos2d::CCString([tempToken UTF8String]);
    MainGameModel::sharedMainGameModel()->setNotificationToken(temp);
    temp->release();
    [token release];
    
#if defined(VERSION_IDS) || defined(VERSION_IDS_SAN)
    //云顶SDK
    [[idsPP sharedInstance]setDeviceToken:deviceToken];
#elif defined(VERSION_JP)
    [[KLPlatform sharedInstance] setPushNotifyDeviceToken:deviceToken];
#endif
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
#if defined(VERSION_IDS) || defined(VERSION_IDS_SAN)
    //云顶SDK
    [[idsPP sharedInstance] setReceiveRemoteNotificationProcessWithUserInfo:userInfo];
#elif defined(VERSION_JP)
    [[KLPlatform sharedInstance] processPushNotification:userInfo];
#endif
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
}

- (void)localNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //每天2个回复体力的时间点，中国时区, 12、19
    NSTimeZone* GMT8Zone=[NSTimeZone timeZoneForSecondsFromGMT:8*60*60];
    NSDate *now=[NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:GMT8Zone];
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:now];
    int year = [dateComps year];
    int month = [dateComps month];
    int day = [dateComps day];
    int hour = [dateComps hour];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:GMT8Zone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr12=[NSString stringWithFormat:@"%d-%02d-%02d 12:00",year,month,day];
    NSDate *today12Date=[dateFormatter dateFromString:dateStr12];
    
    NSString *dateStr19=[NSString stringWithFormat:@"%d-%02d-%02d 19:00",year,month,day];
    NSDate *today19Date=[dateFormatter dateFromString:dateStr19];
    [dateFormatter release];
    
    NSString *notiText=[NSString stringWithUTF8String:ConfigDataModel::shareConfigDataModel()->getTextSNS("sns_14")];
    NSString *notiBackText=[NSString stringWithUTF8String:ConfigDataModel::shareConfigDataModel()->getTextSNS("sns_15")];
    if (hour<12) {//设置当天的体力推送
        [self genNotificationDate:today12Date timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiText notiId:@"today12"];
        [self genNotificationDate:today19Date timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiText notiId:@"today19"];
    }else if (12<hour && hour<19) { //设置当天的19点体力推送
        [self genNotificationDate:today19Date timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiText notiId:@"today19"];
    }
    //设置明天
    NSDate *tom12Date=[NSDate dateWithTimeInterval:24*60*60 sinceDate:today12Date];
    NSDate *tom19Date=[NSDate dateWithTimeInterval:24*60*60 sinceDate:today19Date];
    [self genNotificationDate:tom12Date timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiText notiId:@"tom12"];
    [self genNotificationDate:tom19Date timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiText notiId:@"tom19"];
    
    
    //每天local notification一次，开过开过游戏不提示，没开过搞3天
    NSCalendar *calendar1 = [NSCalendar currentCalendar];
    NSDateComponents *dateComps1 = [calendar1 components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:now];
    int year1 = [dateComps1 year];
    int month1 = [dateComps1 month];
    int day1 = [dateComps1 day];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *openGameStr=[NSString stringWithFormat:@"%d-%02d-%02d 12:00",year1,month1,day1];
    NSDate *openGameDateBase=[dateFormatter1 dateFromString:openGameStr];
    [dateFormatter1 release];
    
    NSDate *openGameDate1=[NSDate dateWithTimeInterval:2*(24*60*60) sinceDate:openGameDateBase];
    NSDate *openGameDate2=[NSDate dateWithTimeInterval:3*(24*60*60) sinceDate:openGameDateBase];
    NSDate *openGameDate3=[NSDate dateWithTimeInterval:4*(24*60*60) sinceDate:openGameDateBase];
    [self genNotificationDate:openGameDate1 timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiBackText notiId:@"openGame1"];
    [self genNotificationDate:openGameDate2 timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiBackText notiId:@"openGame2"];
    [self genNotificationDate:openGameDate3 timeZone:[NSTimeZone defaultTimeZone] repeat:0 alertBody:notiBackText notiId:@"openGame3"];
}

- (void) genNotificationDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone repeat:(NSCalendarUnit)repeat alertBody:(NSString *)alertBody notiId:(NSString*)notiId
{
    UILocalNotification *noti = [[[UILocalNotification alloc] init] autorelease];
    noti.fireDate = date;
    noti.timeZone = timeZone;
    noti.repeatInterval = repeat;
    noti.soundName = UILocalNotificationDefaultSoundName;
    noti.alertBody = alertBody;
    noti.applicationIconBadgeNumber = 1;
    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:notiId forKey:@"notiId"];
    noti.userInfo = infoDic;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:noti];
}


#pragma mark Memory management
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    CCLOG("got applicationDidReceiveMemoryWarning");
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    cocos2d::CCDirector::sharedDirector()->purgeCachedData();
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#if defined(VERSION_IDS)
    if ([[url absoluteString] rangeOfString:@"wxea9ad0b91b0edb9a"].location!=NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self];//微信
    }else if ([[url absoluteString] rangeOfString:@"wb2681384431"].location!=NSNotFound) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboDelegate sharedWeiboDelegate]];
    }else{
        return false;
    }
#elif defined(VERSION_IDS_SAN)
    if ([[url absoluteString] rangeOfString:@"wxfc44e93505a45b75"].location!=NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self];//微信
    }else if ([[url absoluteString] rangeOfString:@"wb602935686"].location!=NSNotFound) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboDelegate sharedWeiboDelegate]];
    }else{
        return false;
    }
#elif defined(VERSION_YW)
    if ([[url absoluteString] rangeOfString:@"wxf084c18fbf1e7b09"].location!=NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self];//微信
    }else if ([[url absoluteString] rangeOfString:@"wb602935686"].location!=NSNotFound) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboDelegate sharedWeiboDelegate]];
    }else{
    #if defined(VERSION_YW_PP)
        if ([[url absoluteString] rangeOfString:@"teiron1915"].location!=NSNotFound) {
            [[PPAppPlatformKit sharedInstance] alixPayResult:url];
            return true;
        } else {
            return false;
        }
    #else
       return false;
    #endif
    }
#else
    return false;
#endif
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
#if defined(VERSION_TW)
    if([[url absoluteString] rangeOfString:@"fb209920902522541"].location!=NSNotFound){
        return [FBSession.activeSession handleOpenURL:url];
    }else{
        return false;
    }
#elif defined(VERSION_JP)
    if([[url absoluteString] rangeOfString:@"fb1381647142092789"].location!=NSNotFound){
        return [FBSession.activeSession handleOpenURL:url];
    }else{
        return false;
    }
#elif defined(VERSION_IDS)
    if ([[url absoluteString] rangeOfString:@"wxea9ad0b91b0edb9a"].location!=NSNotFound || [sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:self];//微信
    }else if ([[url absoluteString] rangeOfString:@"wb2681384431"].location!=NSNotFound || [sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboDelegate sharedWeiboDelegate]];
    #if defined(VERSION_IDS_JB)
    }else if([[url absoluteString] rangeOfString:@"com.appfame.broken.zgdpl"].location!=NSNotFound){
        [[idsPP sharedInstance] parseURL:url
                             application:application];
        return YES;
    #elif defined(VERSION_IDS_UM)
    }else if([[url absoluteString] rangeOfString:@"com.appfame.broken.zgdpl.um"].location!=NSNotFound){
        [[idsPP sharedInstance] parseURL:url
                             application:application];
        return YES;
    #endif
    }else{
        return false;
    }
#elif defined(VERSION_IDS_SAN)
    if ([[url absoluteString] rangeOfString:@"wxfc44e93505a45b75"].location!=NSNotFound || [sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:self];//微信
    }else if ([[url absoluteString] rangeOfString:@"wb602935686"].location!=NSNotFound || [sourceApplication isEqualToString:@"com.sina.weibo"]) {
    	return [WeiboSDK handleOpenURL:url delegate:[WeiboDelegate sharedWeiboDelegate]];
    }else{
        return false;
    }
#elif defined(VERSION_YW)
    if ([[url absoluteString] rangeOfString:@"wxf084c18fbf1e7b09"].location!=NSNotFound || [sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:self];//微信
    }else if ([[url absoluteString] rangeOfString:@"wb602935686"].location!=NSNotFound || [sourceApplication isEqualToString:@"com.sina.weibo"]) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboDelegate sharedWeiboDelegate]];
    }else{
        return false;
    }
#endif
}

#if defined(VERSION_IDS) || defined(VERSION_IDS_SAN)
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return  UIInterfaceOrientationMaskPortrait;
}
#endif

#if !defined(VERSION_TW) && !defined(VERSION_JP)
#pragma mark - wechat
//-(void) onReq:(BaseReq*)req
//{
//    if([req isKindOfClass:[GetMessageFromWXReq class]])
//    {
//        //[self onRequestAppMessage];
//    }
//    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
//    {
//        //ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
//        //[self onShowMediaMessage:temp.message];
//    }
//
//}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode==WXSuccess) {//分享成功
            dispatch_async(dispatch_get_main_queue(), ^{
                CCNotificationCenter::sharedNotificationCenter()->postNotification(SHARE_WECHAT_SUCCESS);
            });
        }
        
        //        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
        //        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
        //
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alert show];
        //        [alert release];
    }
    //    else if([resp isKindOfClass:[SendAuthResp class]])
    //    {
    //        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
    //        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //        [alert show];
    //        [alert release];
    //    }
}
#endif


- (void)dealloc {
    [super dealloc];
}


@end

