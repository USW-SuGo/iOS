//
//  ModifyProduct.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/15.
//

import Foundation

class ModifyProduct {
  static let shared = ModifyProduct()
  
  var productIndex: Int?
  var title: String?
  var price: String?
  var category: String?

  private init() {}
}
