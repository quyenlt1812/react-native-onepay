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

    @ReactMethod
    public void generateURL(OnepayProps opProps, Promise promise) {
        Map<String, String> mapParams = new HashMap<>();
        // Version module of payment gateway, default is “2”
        mapParams.put("vpc_Version", opProps.version);

        // Payment Function, value is “pay”
        mapParams.put("vpc_Command", opProps.command);

        // Unique value for each merchant provided by OnePAY
        mapParams.put("vpc_AccessCode", opProps.accessCode);

        // Unique value for each merchant provided by OnePAY
        mapParams.put("vpc_Merchant", opProps.merchant);

        // Language is used on the payment site Vietnamese: vn, English: en
        mapParams.put("vpc_Locale", opProps.locale);

        // Merchant’s URL Website for redirect response
        mapParams.put("vpc_ReturnURL", opProps.returnUrl);

        // A unique value is created by merchant then send to OnePAY,
        // System.currentTimeMillis for
        // testing
        mapParams.put("vpc_MerchTxnRef", String.valueOf(System.currentTimeMillis()));

        // Order infomation, it could be an order number or brief description of order
        mapParams.put("vpc_OrderInfo", opProps.orderInfo);

        // The amount of the transaction, this value does not have decimal comma. Add
        // “00” before
        // redirect to payment gateway. If transaction amount is VND 25,000 then the
        // amount is
        // 2500000
        mapParams.put("vpc_Amount", opProps.amount + "00");

        // IP address of customer – Do not set a fixed IP
        mapParams.put("vpc_TicketNo", "10.2.20.1");

        // The link of website before redirecting to OnePAY
        mapParams.put("AgainLink", opProps.againLink);

        // Title of payment gateway is shown on the cardholder’s browser
        mapParams.put("Title", opProps.title);

        // Payment Currency, default is VND
        mapParams.put("vpc_Currency", opProps.currency);

        // Payment Card List
        mapParams.put("vpc_CardList", opProps.cardList);

        if (opProps.customerId != "") {
          mapParams.put("vpc_Customer_Id", opProps.customerId);
        }

        if (opProps.customerEmail != "") {
          mapParams.put("vpc_Customer_Email", opProps.customerEmail);
        }

        if (opProps.customerPhone != "") {
          mapParams.put("vpc_Customer_Phone", opProps.customerPhone);
        }

        String vpc_SecureHash = Utils.genSecureHash(mapParams, opProps.secretKey);
        // Hash encryption is for merchant to authenticate and ensure data integrity.
        mapParams.put("vpc_SecureHash", vpc_SecureHash);
        String paramsUrl = Utils.appendQueryFields(mapParams);
        promise.resolve(opProps.baseUrl + "?" + paramsUrl);
    }
}
