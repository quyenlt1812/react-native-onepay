package com.reactnativeonepayhash;

import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import java.util.HashMap;
import java.util.Map;

@ReactModule(name = OnepayHashModule.NAME)
public class OnepayHashModule extends ReactContextBaseJavaModule {
    public static final String NAME = "OnepayHash";

    public OnepayHashModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }


    // Example method
    // See https://reactnative.dev/docs/native-modules-android
    @ReactMethod
    public void multiply(int a, int b, Promise promise) {
        promise.resolve(a * b);
    }

    @ReactMethod
    public void generateURL(String version,
                            String command,
                            String accessCode,
                            String merchant,
                            String locale,
                            String returnUrl,
                            String orderInfo,
                            String amount,
                            String title,
                            String currency,
                            String secretKey,
                            String baseUrl,
                            String againLink,
                            String cardList,
                            Promise promise) {
      Map<String, String> mapParams = new HashMap<>();
      // Version module of payment gateway, default is “2”
      mapParams.put("vpc_Version", version);

      // Payment Function, value is “pay”
      mapParams.put("vpc_Command", command);

      // Unique value for each merchant provided by OnePAY
      mapParams.put("vpc_AccessCode", accessCode);

      // Unique value for each merchant provided by OnePAY
      mapParams.put("vpc_Merchant", merchant);

      // Language is used on the payment site Vietnamese: vn, English: en
      mapParams.put("vpc_Locale", locale);

      // Merchant’s URL Website for redirect response
      mapParams.put("vpc_ReturnURL", returnUrl);

      // A unique value is created by merchant  then send to OnePAY, System.currentTimeMillis for
      // testing
      mapParams.put("vpc_MerchTxnRef", String.valueOf(System.currentTimeMillis()));
      // Order infomation, it could be an order number or brief description of order
      mapParams.put("vpc_OrderInfo", orderInfo);

      // The amount of the transaction, this value does not have decimal comma. Add “00” before
      // redirect to payment gateway. If transaction amount is VND 25,000 then the amount is
      // 2500000
      mapParams.put("vpc_Amount", amount + "00");

      // IP address of customer – Do not set a fixed IP
      mapParams.put("vpc_TicketNo", "10.2.20.1");

      // The link of website before redirecting to OnePAY
      mapParams.put("AgainLink", againLink);

      // Title of payment gateway is shown on the cardholder’s browser
      mapParams.put("Title", title);

      // Payment Currency, default is VND
      mapParams.put("vpc_Currency", currency);

      // Payment Card List
      mapParams.put("vpc_CardList", cardList);

      String vpc_SecureHash = Utils.genSecureHash(mapParams, secretKey);
      // Hash encryption is for merchant to authenticate and ensure data integrity.
      mapParams.put("vpc_SecureHash", vpc_SecureHash);
      String paramsUrl = Utils.appendQueryFields(mapParams);
      promise.resolve(baseUrl + paramsUrl);

  }

    public static native int nativeMultiply(int a, int b);
}
