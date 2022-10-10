//
//  Home.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/29.
//

import Foundation
import UIKit

import Alamofire

struct Home: Codable {
    
    let id: Int
    let imageLink: [String]
    let contactPlace: String
    let updatedAt: String
    let title: String
    let price: Int
    let nickname: String
    let category: String
    
    enum CodingKeys : String, CodingKey {
        case id
        case imageLink
        case contactPlace
        case updatedAt
        case title
        case price
        case nickname
        case category
    }

}
