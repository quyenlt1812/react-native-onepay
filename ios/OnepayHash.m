#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(OnepayHash, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(generateURL:(NSString)version
                  withCommand:(NSString)command
                  withAccessCode:(NSString)accessCode
                  withMerchant:(NSString)merchant
                  withLocale:(NSString)locale
                  withReturnUrl:(NSString)returnUrl
                  withOrderInfo:(NSString)orderInfo
                  withAmount:(NSString)amount
                  withTitle:(NSString)title
                  withCurrency:(NSString)currency
                  withSecretKey:(NSString)secretKey
                  withBaseUrl:(NSString)baseUrl
                  withMerchTxnRef:(NSString)merchTxnRef
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
