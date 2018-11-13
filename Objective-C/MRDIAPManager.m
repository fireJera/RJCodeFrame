//
//  MRDIAPManager.m
//  UncleCon
//
//  Created by Jeremy on 10/02/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "MRDIAPManager.h"
#import "MRDViewmodelHeader.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"
#import "MRDViewControllerHeader.h"
#import "MRDFilePathHelper.h"

static MRDIAPManager * instance = nil;
NSString * MRDIAPCancelString = @"-1";
static NSString * const kIAPReceiptUrl = @"apple/verify-receipt";

@interface MRDIAPManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation MRDIAPManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MRDIAPManager alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

/*
 从Apple查询用户点击购买的产品的信息
 获取到信息以后，根据获取的商品详细信息
 */
- (void)getProductInfo:(NSString *)productIdentifier orderId:(NSString *)orderId
{
    //移除上次未完成的交易订单
    if (!orderId) {
        if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
        {
            [_IAPDelegate IAPFailedWithWrongInfor:@"订单创建失败"];
        }
    }
    [self p_removelUncompleteTransactionBeforeStart];
    _orderId = orderId;
    if (![SKPaymentQueue canMakePayments])
    {
        if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
        {
            [_IAPDelegate IAPFailedWithWrongInfor:@"不允许程序内付费购买"];
        }
        return;
    }

    if (productIdentifier.length > 0)
    {
        NSArray * product = [[NSArray alloc] initWithObjects:productIdentifier, nil];
        NSSet *set = [NSSet setWithArray:product];
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
    }
    else
    {
        if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
        {
            [_IAPDelegate IAPFailedWithWrongInfor:@"商品ID为空"];
        }
    }
}

- (void)checktAllFailOrder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directoryPath = [MRDFilePathHelper iapReceiptPath];
    
    NSError * error;
    if ([fileManager fileExistsAtPath:directoryPath]) {
        NSArray * cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
        if (error == nil) {
            for (NSString * name in cacheFileNameArray) {
                NSString * orderId;
                NSString * filePath = [directoryPath stringByAppendingPathComponent:name];
//                NSDictionary * attributeDic = [fileManager attributesOfItemAtPath:filePath error:&error];
                if (!error) {
                    orderId = [name substringToIndex:name.length - 6];
                }
            
                if (!orderId || [orderId isEqualToString:@"0"]) {
                    continue;
                }
                NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
                NSString * receipt = [contentDic objectForKey:@"receipt"];
                NSString * transId = [contentDic objectForKey:@"transId"];
                [self p_verifyReceipt:receipt transId:transId orderId:orderId result:nil];
            }
        }
    }
}

#pragma mark -- 结束上次未完成的交易 防止串单
-(void)p_removelUncompleteTransactionBeforeStart {
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    for (SKPaymentTransaction * transaction in transactions) {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
//    if (transactions.count > 0) {
//        //检测是否有未完成的交易
//        SKPaymentTransaction* transaction = [transactions firstObject];
//        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
//            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            return;
//        }
//    }
}

/*
 查询成功后的回调
 经由getProductInfo函数发起的产品信息查询，成功后返回执行的回调。再更具回调内容发起购买请求
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;

    if (myProduct.count == 0)
    {
        if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
        {
            [_IAPDelegate IAPFailedWithWrongInfor:@"无法获取商品信息"];
        }
        return;
    }
    
    SKProduct * product = myProduct[0];

    SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = self.orderId;
    //发起购买操作，下边的代码
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

/*
 查询失败后的回调
 */
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
    {
        [_IAPDelegate IAPFailedWithWrongInfor:@"购买失败"];
    }
    NSLog(@"打印错误信息：%@",[error localizedDescription]);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
                //交易完成
            case SKPaymentTransactionStatePurchased:
                //发送购买凭证到服务器验证是否有效
                [self completeTransaction:transaction];
                break;
                //交易失败
            case SKPaymentTransactionStateFailed:
                [self p_failedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                //已经购买过该商品
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过该商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                //商品添加进列表
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"StatePurchasing");
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"StateDeferred");
                break;
        }
    }
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error NS_AVAILABLE_IOS(3_0) {
    NSLog(@"---------restoreCompletedTransactionsFailedWithError--------");
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue NS_AVAILABLE_IOS(3_0) {
    NSLog(@"---------paymentQueueRestoreCompletedTransactionsFinished--------");
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads NS_AVAILABLE_IOS(6_0) {
    NSLog(@"---------updatedDownloads--------");
}

- (void)p_failedTransaction:(SKPaymentTransaction *)transaction {
    if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
    {
        NSString * errStr;
        switch (transaction.error.code) {
            case SKErrorUnknown:
                errStr = @"未知的错误，您可能正在使用越狱手机";
                break;
            case SKErrorPaymentCancelled:
                errStr = MRDIAPCancelString;
                break;
            case SKErrorClientInvalid:
                errStr = @"当前苹果账户无法购买商品(如有疑问，可以询问苹果客服)";
                break;
            case SKErrorPaymentInvalid:
                errStr = @"支付参数错误";
                break;
            case SKErrorPaymentNotAllowed:
                errStr = @"当前苹果设备无法购买商品(如有疑问，可以询问苹果客服)";
                break;
            case SKErrorStoreProductNotAvailable:
                errStr = @"当前商品不可用";
                break;
            default:
                errStr = [transaction.error localizedDescription];
                break;
        }
        [_IAPDelegate IAPFailedWithWrongInfor:errStr];
        NSLog(@"打印错误信息：%@",[transaction.error localizedDescription]);
    }
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
}

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    return YES;
}

- (NSString *)p_receiptString {
    NSURL * receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData * receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString * base64String = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return base64String;
}

//交易成功，与服务器比对传输货单号
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSString * transactionReceiptString = [self p_receiptString];
    NSString * trasId = transaction.transactionIdentifier;
    if (!trasId) {
        return;
    }
    [self p_saveIAPReceipt:transactionReceiptString transId:trasId];
    [self checktAllFailOrder];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)p_verifyReceipt:(NSString *)transactionReceiptString
                transId:(NSString *)transId
                orderId:(NSString *)orderId
                 result:(MRDNetMessageBlock)resultBolck {
    if (!orderId) {
        return;
    }
    
    NSString * urlString = [NSString stringWithFormat:@"%@?token=%@", kIAPReceiptUrl, MRDINSTANCE_USER.token];
    NSDictionary * dic = @{@"receipt": transactionReceiptString, @"transaction_id": transId, @"order_id": orderId};
    [MRDNetWorkManager multipartPost:urlString withParameters:dic result:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            if ([result[@"ok"] intValue] == 1) {
                [self p_successConsumptionOfGoodsWithOrder:orderId];
                if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPPaySuccessFunctionWithBase64:)])
                {
                    [_IAPDelegate IAPPaySuccessFunctionWithBase64:transactionReceiptString];
                }
                if (resultBolck) {
                    resultBolck(YES, nil);
                }
                return ;
            }
        }
        [self p_verrifyAgain:transactionReceiptString transId:transId orderId:orderId result:resultBolck];
    }];
}

- (void)p_verrifyAgain:(NSString *)transactionReceiptString
               transId:(NSString *)transId
               orderId:(NSString *)orderId
                result:(MRDNetMessageBlock)resultBolck {
    NSString * urlString = [NSString stringWithFormat:@"%@?token=%@", kIAPReceiptUrl, MRDINSTANCE_USER.token];
    NSDictionary * dic = @{@"receipt": transactionReceiptString, @"transaction_id": transId, @"order_id": orderId};
    [MRDNetWorkManager multipartPost:urlString withParameters:dic result:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            if ([result[@"ok"] intValue] == 1) {
                [self p_successConsumptionOfGoodsWithOrder:orderId];
                if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPPaySuccessFunctionWithBase64:)])
                {
                    [_IAPDelegate IAPPaySuccessFunctionWithBase64:transactionReceiptString];
                }
                if (resultBolck) {
                    resultBolck(YES, nil);
                }
                return ;
            }
        }
        if (IsDictionaryWithItems(result)) {
            NSString * msg = result[@"msg"];
            NSString * str = msg.length > 0 ? msg : @"验证失败";
            if (_IAPDelegate && [_IAPDelegate respondsToSelector:@selector(IAPFailedWithWrongInfor:)])
            {
                [_IAPDelegate IAPFailedWithWrongInfor:str];
            }
        }
    }];
}

#pragma mark -- 存储成功订单
- (void)p_saveIAPReceipt:(NSString *)receipt transId:(NSString *)transId {
    NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
    [mdic setValue:receipt forKey:@"receipt"];
    [mdic setValue:transId forKey:@"transId"];
    NSString * successReceiptPath = [NSString stringWithFormat:@"%@/%@.plist", [MRDFilePathHelper iapReceiptPath], self.orderId];
    //存储购买成功的凭证
    [mdic writeToFile:successReceiptPath atomically:YES];
}

#pragma mark -- 根据订单号来移除本地凭证的方法
- (void)p_successConsumptionOfGoodsWithOrder:(NSString * )orderId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSString * receiptPath = [NSString stringWithFormat:@"%@/%@.plist", [MRDFilePathHelper iapReceiptPath], orderId];
    if ([fileManager fileExistsAtPath:receiptPath]) {
        BOOL ifRemove =  [fileManager removeItemAtPath:receiptPath error:&error];
        if (ifRemove) {
            NSLog(@"成功订单移除成功");
        }else{
            NSLog(@"成功订单移除失败");
        }
    } else {
        NSLog(@"本地无与之匹配的订单");
    }
}

@end
