enum NetworkType: String {
  case wifi = "en0"
  case cellular = "pdp_ip0"
}

class HashHelpers {
  func secureHashKey(dict:[String:String], secretKey: String) -> String {
    print("SMLog 123", dict)
    var stringDict = ""
    let dictSort = dict.sorted { $0.0 < $1.0 }
    var index = 0
    for (key, value) in dictSort {
      index = index + 1
      if key.starts(with: "vpc_") {
        if index < dictSort.count {
          stringDict = stringDict + "\(key)=\(value)" + "&"
        }else {
          stringDict = stringDict + "\(key)=\(value)"
        }
      }
    }
    
    let hmacData2 = hmac(hashName:"SHA256", message:stringDict.data(using:.utf8)!, key: secretKey.hexaData)
    let str = hmacData2!.hexEncodedString(options: .upperCase)
    return str
  }
  
  func hmac(hashName:String, message:Data, key:Data) -> Data? {
    let algos = ["SHA1":   (kCCHmacAlgSHA1,   CC_SHA1_DIGEST_LENGTH),
                 "MD5":    (kCCHmacAlgMD5,    CC_MD5_DIGEST_LENGTH),
                 "SHA224": (kCCHmacAlgSHA224, CC_SHA224_DIGEST_LENGTH),
                 "SHA256": (kCCHmacAlgSHA256, CC_SHA256_DIGEST_LENGTH),
                 "SHA384": (kCCHmacAlgSHA384, CC_SHA384_DIGEST_LENGTH),
                 "SHA512": (kCCHmacAlgSHA512, CC_SHA512_DIGEST_LENGTH)]
    guard let (hashAlgorithm, length) = algos[hashName]  else { return nil }
    var macData = Data(count: Int(length))
    
    macData.withUnsafeMutableBytes { (macBytes: UnsafeMutableRawBufferPointer) in
      message.withUnsafeBytes { (messageBytes: UnsafeRawBufferPointer) in
        key.withUnsafeBytes {(keyBytes : UnsafeRawBufferPointer) in
          CCHmac(CCHmacAlgorithm(hashAlgorithm),
                 keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                 key.count,
                 messageBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                 message.count,
                 macBytes.baseAddress?.assumingMemoryBound(to: UInt8.self))
        }
      }
    }
    return macData
  }
  
  func getAddress(for network: NetworkType) -> String? {
    var address: String?
    
    // Get list of all interfaces on the local machine:
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
      let interface = ifptr.pointee
      
      // Check for IPv4 or IPv6 interface:
      let addrFamily = interface.ifa_addr.pointee.sa_family
      if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
        
        // Check interface name:
        let name = String(cString: interface.ifa_name)
        if name == network.rawValue {
          
          // Convert interface address to a human readable string:
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                      &hostname, socklen_t(hostname.count),
                      nil, socklen_t(0), NI_NUMERICHOST)
          address = String(cString: hostname)
        }
      }
    }
    freeifaddrs(ifaddr)
    return address
  }
}


@objc(OnepayHash)
class OnepayHash: NSObject {
  
  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    resolve(a*b)
  }
  
  @objc(generateURL:withCommand:withAccessCode:withMerchant:withLocale:withReturnUrl:withOrderInfo:withAmount:withTitle: withCurrency:withSecretKey:withBaseUrl:withMerchTxnRef:withResolver:withRejecter:)
  func generateURL( version:String,
                    command:String,
                    accessCode:String,
                    merchant:String,
                    locale: String,
                    returnUrl:String,
                    orderInfo:String,
                    amount:String,
                    title:String,
                    currency: String,
                    secretKey: String,
                    baseUrl: String,
                    merchTxnRef:String,
                    resolve:RCTPromiseResolveBlock,
                    reject:RCTPromiseRejectBlock) -> Void {
    var ticketNo:String = HashHelpers().getAddress(for: .wifi) ?? ""
    if ticketNo.elementsEqual("") {
      ticketNo = HashHelpers().getAddress(for: .cellular) ?? ""
    }
    if ticketNo.elementsEqual("") {
      ticketNo = "10.2.20.1"
    }
    var amountString = amount.replacingOccurrences(of: ".", with: "") + "00"
    amountString = amountString.replacingOccurrences(of: ",", with: "")
    
    var dict = [
      "vpc_Version":version,
      "vpc_Command":command,
      "vpc_AccessCode":accessCode,
      "vpc_Merchant":merchant,
      "vpc_Locale":locale,
      "vpc_ReturnURL":returnUrl,
      "vpc_MerchTxnRef":merchTxnRef,
      "vpc_OrderInfo":orderInfo,
      "vpc_Amount":amountString,
      "vpc_TicketNo":ticketNo,
      "Title":title,
      "vpc_Currency":currency,
      "vpc_CardList": "INTERNATIONAL"
    ]
    var queryItems = [
      URLQueryItem(name: "vpc_Version", value: version),
      URLQueryItem(name: "vpc_Command", value: command),
      URLQueryItem(name: "vpc_AccessCode", value: accessCode),
      URLQueryItem(name: "vpc_Merchant", value: merchant),
      URLQueryItem(name: "vpc_Locale", value: locale),
      URLQueryItem(name: "vpc_ReturnURL", value: returnUrl),
      URLQueryItem(name: "vpc_MerchTxnRef", value: merchTxnRef),
      URLQueryItem(name: "vpc_OrderInfo", value: orderInfo),
      URLQueryItem(name: "vpc_Amount", value: amountString),
      URLQueryItem(name: "vpc_TicketNo", value: ticketNo),
      URLQueryItem(name: "Title", value: title),
      URLQueryItem(name: "vpc_Currency", value: currency),
      URLQueryItem(name: "vpc_CardList", value: "INTERNATIONAL")
    ]
    queryItems.append(
      URLQueryItem(name: "AgainLink", value: "https://mtf.onepay.vn")
    )
    dict["AgainLink"] = "https://mtf.onepay.vn"
    
    //      if let customerPhone = customerPhone {
    //        queryItems.append(
    //          URLQueryItem(name: "vpc_Customer_Phone", value: customerPhone)
    //        )
    //        dict["vpc_Customer_Phone"] = customerPhone
    //      }
    //      if let customerEmail = customerEmail {
    //        queryItems.append(
    //          URLQueryItem(name: "vpc_Customer_Email", value: customerEmail)
    //        )
    //        dict["vpc_Customer_Email"] = customerEmail
    //      }
    //      if let customerId = customerId {
    //        queryItems.append(
    //          URLQueryItem(name: "vpc_Customer_Id", value: customerId)
    //        )
    //        dict["vpc_Customer_Id"] = customerId
    //      }
    queryItems.append(
      URLQueryItem(name: "vpc_SecureHash", value: HashHelpers().secureHashKey(dict: dict, secretKey: secretKey))
    )
    print("SMLog Hash", HashHelpers().secureHashKey(dict: dict, secretKey: secretKey))
    var urlComps = URLComponents(string: baseUrl)!
    urlComps.queryItems = queryItems
    let result = urlComps.url!
    resolve(result.absoluteString)
  }
}
