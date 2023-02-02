//
//  PostProtocol.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/18.
//

import Foundation

protocol PostProtocol {
  var productIndex: Int { get }
  var title: String { get }
  var price: String { get }
  var category: String { get }
  var contactPlace: String { get }
  var updatedAt: String { get }
}
