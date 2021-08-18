//
//  Utils.swift
//  OnepayHash
//
//  Created by Le Tu Quyen on 17/08/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation

class Helpers {
  func secureHashKey(dict:[String:String], secretKey: String) -> String {
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
