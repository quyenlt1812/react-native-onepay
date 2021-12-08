#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(OnepayHash, NSObject)

RCT_EXTERN_METHOD(generateURL:(NSDictionary *)opProps
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
