package com.reactnativeonepayhash;

import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
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

    @ReactMethod
    public void generateURL(ReadableMap opProps, Promise promise) {
        Map<String, String> mapParams = new HashMap<>();

        // Version module of payment gateway, default is “2”
        mapParams.put("vpc_Version", opProps.getString("version"));

        // Payment Function, value is “pay”
        mapParams.put("vpc_Command", opProps.getString("command"));

        // Unique value for each merchant provided by OnePAY
        mapParams.put("vpc_AccessCode", opProps.getString("accessCode"));

        // Unique value for each merchant provided by OnePAY
        mapParams.put("vpc_Merchant", opProps.getString("merchant"));

        // Language is used on the payment site Vietnamese: vn, English: en
        mapParams.put("vpc_Locale", opProps.getString("locale"));

        // Merchant’s URL Website for redirect response
        mapParams.put("vpc_ReturnURL", opProps.getString("returnUrl"));

        // A unique value is created by merchant then send to OnePAY,
        // System.currentTimeMillis for
        // testing
        mapParams.put("vpc_MerchTxnRef", String.valueOf(System.currentTimeMillis()));

        // Order infomation, it could be an order number or brief description of order
        mapParams.put("vpc_OrderInfo", opProps.getString("orderInfo"));

        // The amount of the transaction, this value does not have decimal comma. Add
        // “00” before
        // redirect to payment gateway. If transaction amount is VND 25,000 then the
        // amount is
        // 2500000
        mapParams.put("vpc_Amount", opProps.getString("amount") + "00");

        // IP address of customer – Do not set a fixed IP
        mapParams.put("vpc_TicketNo", "10.2.20.1");

        // The link of website before redirecting to OnePAY
        mapParams.put("AgainLink", opProps.getString("againLink"));

        // Title of payment gateway is shown on the cardholder’s browser
        mapParams.put("Title", opProps.getString("title"));

        // Payment Currency, default is VND
        mapParams.put("vpc_Currency", opProps.getString("currency"));

        // Payment Card List
        mapParams.put("vpc_CardList", opProps.getString("cardList"));

        if (opProps.getString("customerId") != "") {
          mapParams.put("vpc_Customer_Id", opProps.getString("customerId"));
        }

        if (opProps.getString("customerEmail") != "") {
          mapParams.put("vpc_Customer_Email", opProps.getString("customerEmail"));
        }

        if (opProps.getString("customerPhone") != "") {
          mapParams.put("vpc_Customer_Phone", opProps.getString("customerPhone"));
        }

        String vpc_SecureHash = Utils.genSecureHash(mapParams, opProps.getString("secretKey"));
        // Hash encryption is for merchant to authenticate and ensure data integrity.
        mapParams.put("vpc_SecureHash", vpc_SecureHash);
        String paramsUrl = Utils.appendQueryFields(mapParams);
        promise.resolve(opProps.getString("baseUrl") + "?" + paramsUrl);
    }
}
