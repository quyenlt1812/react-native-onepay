//
//  OnepayProps.swift
//  OnepayHash
//
//  Created by Le Tu Quyen on 09/12/2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Foundation

class OnepayProps {
  var version: String
  var command: String
  var accessCode: String
  var merchant: String
  var locale: String
  var returnUrl: String
  var orderInfo: String
  var amount: String
  var title: String
  var currency: String
  var secretKey: String
  var baseUrl: String
  var merchTxnRef: String
  var againLink: String
  var cardList: String
  var customerId: String?
  var customerEmail: String?
  var customerPhone: String?
  
  init() {}
}
