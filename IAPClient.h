//
//  IAPClient.h
//  bomb
//
//  Created by 陆 明俊 on 13-5-23.
//  Copyright (c) 2013年 Black Pearl. All rights reserved.
//

#ifndef __bomb__IAPClient__
#define __bomb__IAPClient__

#include "cocos2d.h"

using namespace std;
USING_NS_CC;

class Product
: public CCObject
{
    
public:
    Product();
    ~Product();
    
    CC_SYNTHESIZE_RETAIN(CCString *, _productIdentifier, ProductIdentifier);
    CC_SYNTHESIZE_RETAIN(CCString *, _localizedTitle, LocalizedTitle);
    CC_SYNTHESIZE_RETAIN(CCString *, _localizedDescription, LocalizedDescription);
    CC_SYNTHESIZE_RETAIN(CCString *, _localizedPrice, LocalizedPrice);
    CC_SYNTHESIZE(int, _count, Count);
    CC_SYNTHESIZE(float, _price, Price);
};

class IAPClient
: public CCObject
{
public:
    IAPClient();
    ~IAPClient();
    static IAPClient* sharedIAPClient();
    
    CC_SYNTHESIZE_RETAIN(CCArray *, _productList, ProductList);
    
    //apple
    void checkStore();
    void purchaseDisable();
    void requestProductData();
    void gotProductData();
    void buyProduct(const char* productId);
    void buyProductJP(const char* productId, const char* extInfo);
    void buyProductSuccess(CCString* recepit, CCString* base64Recepit);
    void buyProductFail();
    void finishTransaction(string tid);
    
#if defined(VERSION_IDS)
    //云顶
    void showIdsStore();
#endif
};



#endif /* defined(__bomb__IAPClient__) */
