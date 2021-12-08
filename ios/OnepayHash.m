#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(OnepayHash, NSObject)

RCT_EXTERN_METHOD(generateURL:(NSObject)opProps
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
