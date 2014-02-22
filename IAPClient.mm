//
//  IAPClient.cpp
//  bomb
//
//  Created by 陆 明俊 on 13-5-23.
//  Copyright (c) 2013年 Black Pearl. All rights reserved.
//

#include "IAPClient.h"
#import "IAPManager.h"
#include "GlobalDef.h"
#include "LoadingLayer.h"
#include "MainGameController.h"
#include "ReceiptInfo.h"
#if defined(VERSION_IDS) || defined(VERSION_IDS_SAN)
#import <IDS/IDSHeader.h>
#endif

#if defined(VERSION_JP)
#import <KunlunFB_v1.2.3.31/KLPlatformKit.h>
#import "SDKKunlun.h"
#endif

#pragma mark - product
Product::Product()
{
    _productIdentifier=NULL;
    _localizedTitle=NULL;
    _localizedDescription=NULL;
    _localizedPrice=NULL;
    _count=0;
}

Product::~Product()
{
    CC_SAFE_RELEASE_NULL(_productIdentifier);
    CC_SAFE_RELEASE_NULL(_localizedTitle);
    CC_SAFE_RELEASE_NULL(_localizedDescription);
    CC_SAFE_RELEASE_NULL(_localizedPrice);
}

#pragma mark - lifecycle
static IAPClient *s_IAPClient=NULL;

IAPClient* IAPClient::sharedIAPClient()
{
    if (!s_IAPClient)
    {
        s_IAPClient = new IAPClient();
    }
    
    return s_IAPClient;
}

IAPClient::IAPClient()
{
    _productList=new CCArray;
}

IAPClient::~IAPClient()
{
    CC_SAFE_RELEASE_NULL(_productList);
}

#pragma mark - app store
void IAPClient::checkStore()
{
    [[IAPManager sharedIAPManager] checkStore];
}

void IAPClient::purchaseDisable()
{
    CCScene *runningScene=CCDirector::sharedDirector()->getRunningScene();
    CCLayer * loadingLayer=(CCLayer *)runningScene->getChildByTag(TAG_LOADING);
    if (loadingLayer) {//去除loading，特殊处理
        loadingLayer->removeFromParent();
    }
    
    CCNotificationCenter::sharedNotificationCenter()->postNotification(APP_STORE_PURCHASE_DISABLE);
}

void IAPClient::requestProductData()
{
    [[IAPManager sharedIAPManager] requestProductData];
    
    BaseController *runningScene=dynamic_cast<BaseController *>(CCDirector::sharedDirector()->getRunningScene());
    runningScene->showLoading(APP_STORE_PRODUCT_LIST);
    //[iapManager release];
}

void IAPClient::gotProductData()
{
    CCNotificationCenter::sharedNotificationCenter()->postNotification(APP_STORE_PRODUCT_LIST);
    CCNotificationCenter::sharedNotificationCenter()->postNotification(cmdLoading(APP_STORE_PRODUCT_LIST).c_str());
}

void IAPClient::buyProduct(const char *productId)
{
    [[IAPManager sharedIAPManager] buyProduct:[NSString stringWithUTF8String:productId]];
    
    BaseController *runningScene=dynamic_cast<BaseController *>(CCDirector::sharedDirector()->getRunningScene());
    runningScene->showLoading(APP_STORE_BUY);//购买loading,特殊处理
}

void IAPClient::buyProductJP(const char *productId, const char *extInfo)
{
#if defined(VERSION_JP)
    BaseController *runningScene=dynamic_cast<BaseController *>(CCDirector::sharedDirector()->getRunningScene());
    runningScene->showLoading(APP_STORE_BUY);//购买loading,特殊处理
    
    SDKKunlun::sharedSDKKunlun()->setProductId(ccs(productId));
    [[KLPlatform sharedInstance] purchase:[NSString stringWithUTF8String:productId] partnerOrderId:[NSString stringWithUTF8String:extInfo]];
#endif
}

void IAPClient::buyProductSuccess(cocos2d::CCString *recepit, cocos2d::CCString *base64Recepit)
{
    //    CCScene *runningScene=CCDirector::sharedDirector()->getRunningScene();
    //    CCLayer * loadingLayer=(CCLayer *)runningScene->getChildByTag(TAG_LOADING);
    //    if (loadingLayer) {//购买成功，去除loading，特殊处理
    //        loadingLayer->removeFromParent();
    //    }
#ifndef VERSION_JP
    ReceiptInfo *receiptInfo=new ReceiptInfo;
    receiptInfo->setReceipt(recepit);
    receiptInfo->setBase64Receipt(base64Recepit);
    
    //本地记录订单号
    CCUserDefault::sharedUserDefault()->setStringForKey(UD_RECEPIT.c_str(), receiptInfo->getReceipt()->m_sString);
    CCUserDefault::sharedUserDefault()->setStringForKey(UD_RECEPIT_BASE64.c_str(), receiptInfo->getBase64Receipt()->m_sString);
    CCUserDefault::sharedUserDefault()->flush();
    
    CCNotificationCenter::sharedNotificationCenter()->postNotification(APP_STORE_BUY_SUCCESS,receiptInfo);
    CCNotificationCenter::sharedNotificationCenter()->postNotification(cmdLoading(APP_STORE_BUY).c_str());
    
    receiptInfo->release();
#endif
}

void IAPClient::buyProductFail()
{
    CCNotificationCenter::sharedNotificationCenter()->postNotification(cmdLoading(APP_STORE_BUY).c_str());
}

void IAPClient::finishTransaction(string tid)
{
    NSString *transactionId=[[NSString alloc] initWithUTF8String:tid.c_str()];
    [[IAPManager sharedIAPManager] finishTransaction:transactionId];
    [transactionId release];
}

#pragma mark - ids
#if defined(VERSION_IDS)
void IAPClient::showIdsStore()
{
    [[idsPP sharedInstance] showYunDingPayWithGoodsCode:nil];
}
#endif
