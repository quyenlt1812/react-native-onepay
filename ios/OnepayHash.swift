import Foundation

enum NetworkType: String {
  case wifi = "en0"
  case cellular = "pdp_ip0"
}

class HashHelpers {
  func secureHashKey(dict: [String: String], secretKey: String) -> String {
    var stringDict = ""
    let dictSort = dict.sorted { $0.0 < $1.0 }
    var index = 0
    for (key, value) in dictSort {
      index = index + 1
      if key.starts(with: "vpc_") {
        if index < dictSort.count {
          stringDict = stringDict + "\(key)=\(value)" + "&"
        } else {
          stringDict = stringDict + "\(key)=\(value)"
        }
      }
    }

    let hmacData2 = hmac(hashName: "SHA256", message: stringDict.data(using: .utf8)!, key: secretKey.hexaData)
    let str = hmacData2!.hexEncodedString(options: .upperCase)
    return str
  }

  func hmac(hashName: String, message: Data, key: Data) -> Data? {
    let algos = ["SHA1": (kCCHmacAlgSHA1, CC_SHA1_DIGEST_LENGTH),
      "MD5": (kCCHmacAlgMD5, CC_MD5_DIGEST_LENGTH),
      "SHA224": (kCCHmacAlgSHA224, CC_SHA224_DIGEST_LENGTH),
      "SHA256": (kCCHmacAlgSHA256, CC_SHA256_DIGEST_LENGTH),
      "SHA384": (kCCHmacAlgSHA384, CC_SHA384_DIGEST_LENGTH),
      "SHA512": (kCCHmacAlgSHA512, CC_SHA512_DIGEST_LENGTH)]
    guard let (hashAlgorithm, length) = algos[hashName] else { return nil }
    var macData = Data(count: Int(length))

    macData.withUnsafeMutableBytes { (macBytes: UnsafeMutableRawBufferPointer) in
      message.withUnsafeBytes { (messageBytes: UnsafeRawBufferPointer) in
        key.withUnsafeBytes { (keyBytes: UnsafeRawBufferPointer) in
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

class OnepayProps: NSObject {
  var version: String = "2"
  var command: String = "pay"
  var accessCode: String = ""
  var merchant: String = ""
  var locale: String = "vi"
  var returnUrl: String = ""
  var orderInfo: String = ""
  var amount: String = ""
  var title: String = ""
  var currency: String = ""
  var secretKey: String = ""
  var baseUrl: String = ""
  var merchTxnRef: String = ""
  var againLink: String = ""
  var cardList: String = ""
  var customerId: String?
  var customerEmail: String?
  var customerPhone: String?
}


@objc(OnepayHash)
class OnepayHash: NSObject {
  @objc(generateURL:withResolver:withRejecter:)
  func generateURL(opProps: OnepayProps,
                   resolve: RCTPromiseResolveBlock,
                   reject: RCTPromiseRejectBlock) -> Void {
    var ticketNo: String = HashHelpers().getAddress(for: .wifi) ?? ""
    if ticketNo.elementsEqual("") {
      ticketNo = HashHelpers().getAddress(for: .cellular) ?? ""
    }
    if ticketNo.elementsEqual("") {
      ticketNo = "10.2.20.1"
    }
    var amountString = opProps.amount.replacingOccurrences(of: ".", with: "") + "00"
    amountString = amountString.replacingOccurrences(of: ",", with: "")

    var dict = [
      "vpc_Version": opProps.version,
      "vpc_Command": opProps.command,
      "vpc_AccessCode": opProps.accessCode,
      "vpc_Merchant": opProps.merchant,
      "vpc_Locale": opProps.locale,
      "vpc_ReturnURL": opProps.returnUrl,
      "vpc_MerchTxnRef": opProps.merchTxnRef,
      "vpc_OrderInfo": opProps.orderInfo,
      "vpc_Amount": amountString,
      "vpc_TicketNo": ticketNo,
      "Title": opProps.title,
      "vpc_Currency": opProps.currency,
      "vpc_CardList": opProps.cardList,
    ]
    var queryItems = [
      URLQueryItem(name: "vpc_Version", value: opProps.version),
      URLQueryItem(name: "vpc_Command", value: opProps.command),
      URLQueryItem(name: "vpc_AccessCode", value: opProps.accessCode),
      URLQueryItem(name: "vpc_Merchant", value: opProps.merchant),
      URLQueryItem(name: "vpc_Locale", value: opProps.locale),
      URLQueryItem(name: "vpc_ReturnURL", value: opProps.returnUrl),
      URLQueryItem(name: "vpc_MerchTxnRef", value: opProps.merchTxnRef),
      URLQueryItem(name: "vpc_OrderInfo", value: opProps.orderInfo),
      URLQueryItem(name: "vpc_Amount", value: amountString),
      URLQueryItem(name: "vpc_TicketNo", value: ticketNo),
      URLQueryItem(name: "Title", value: opProps.title),
      URLQueryItem(name: "vpc_Currency", value: opProps.currency),
      URLQueryItem(name: "vpc_CardList", value: opProps.cardList)
    ]
    
    if (opProps.againLink != "") {
      queryItems.append(
        URLQueryItem(name: "AgainLink", value: opProps.againLink)
      )
      dict["AgainLink"] = opProps.againLink
    }
    
    

    if (opProps.customerPhone != nil) {
      queryItems.append(
        URLQueryItem(name: "vpc_Customer_Phone", value: opProps.customerPhone)
      )
      dict["vpc_Customer_Phone"] = opProps.customerPhone
    }
    if (opProps.customerEmail != nil) {
      queryItems.append(
        URLQueryItem(name: "vpc_Customer_Email", value: opProps.customerEmail)
      )
      dict["vpc_Customer_Email"] = opProps.customerEmail
    }
    if (opProps.customerId != nil) {
      queryItems.append(
        URLQueryItem(name: "vpc_Customer_Id", value: opProps.customerId)
      )
      dict["vpc_Customer_Id"] = opProps.customerId
    }

    queryItems.append(
      URLQueryItem(name: "vpc_SecureHash", value: HashHelpers().secureHashKey(dict: dict, secretKey: opProps.secretKey))
    )

    var urlComps = URLComponents(string: opProps.baseUrl)!
    urlComps.queryItems = queryItems
    let result = urlComps.url!
    resolve(result.absoluteString)
  }
}
