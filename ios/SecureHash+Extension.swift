//
//  SecureHash+Extension.swift
//  OnepayHash
//
//  Created by Le Tu Quyen on 17/08/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation

extension String {
  var localized: String {
    var lang : String = "en"
    if let defaultLang =  UserDefaults.standard.object(forKey: "DEFAULT-LANGUAGUE") as? String , defaultLang != "ENGLISH" {
      lang = "vi"
    } else  if (NSLocale.preferredLanguages[0].range(of: "vi") != nil){
      lang = "vi"
    }
    
    let path = Bundle.main.path(forResource: lang, ofType: "lproj")
    let bundle = Bundle(path: path!)
    
    return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
  }
}

extension URL {
  public var queryParameters: [String: String]? {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
      let queryItems = components.queryItems else { return nil }
    return queryItems.reduce(into: [String: String]()) { (result, item) in
      result[item.name] = item.value
    }
  }
  
  func getQueryStringParameter(param: String) -> String? {
    guard let url = URLComponents(string: self.absoluteString) else { return nil }
    return url.queryItems?.first(where: { $0.name == param })?.value
  }
}

extension Data {
  struct HexEncodingOptions: OptionSet {
    let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
  }
  
  func hexEncodedString(options: HexEncodingOptions = []) -> String {
    let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
    var chars: [unichar] = []
    chars.reserveCapacity(2 * count)
    for byte in self {
      chars.append(hexDigits[Int(byte / 16)])
      chars.append(hexDigits[Int(byte % 16)])
    }
    return String(utf16CodeUnits: chars, count: chars.count)
  }
}

extension StringProtocol {
  var hexaData: Data { .init(hexa) }
  var hexaBytes: [UInt8] { .init(hexa) }
  private var hexa: UnfoldSequence<UInt8, Index> {
    sequence(state: startIndex) { start in
      guard start < self.endIndex else { return nil }
      let end = self.index(start, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
      defer { start = end }
      return UInt8(self[start..<end], radix: 16)
    }
  }
  
  var hexaEncode: [UInt8] {
    var startIndex = self.startIndex
    return (0..<count/2).compactMap { _ in
      let endIndex = index(after: startIndex)
      defer { startIndex = index(after: endIndex) }
      return UInt8(self[startIndex...endIndex], radix: 16)
    }
  }
}

extension Sequence where Element == UInt8 {
  var data: Data { .init(self) }
  var hexa: String { map { .init(format: "%02x", $0) }.joined() }
}

