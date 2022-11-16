//
//  UINavigationItem+Extensions.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/17.
//

import UIKit
import Foundation

// navigationBarItem Extension
extension UINavigationItem {
    
  func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: String) -> UIBarButtonItem {
      
      let button = UIButton(type: .system)
      button.setImage(UIImage(systemName: symbolName), for: .normal)
      // action은 objc 함수로 define -> if 내가 필요 시
      button.addTarget(target, action: action, for: .touchUpInside)
      button.tintColor = .black
          
      let barButtonItem = UIBarButtonItem(customView: button)
      barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
      barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
      barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
          
      return barButtonItem
  }
  
  func makeWordButton(_ target: Any?, action: Selector, title: String) -> UIBarButtonItem {
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    let button = UIButton(type: .system)
    print(title)
    
    button.setTitle("완료", for: .normal)
    button.setTitleColor(colorLiteralGreen, for: .normal)
    button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 18)
    // action은 objc 함수로 define -> if 내가 필요 시
    button.addTarget(target, action: action, for: .touchUpInside)
    button.tintColor = colorLiteralGreen
        
    let barButtonItem = UIBarButtonItem(customView: button)
    barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
//    barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
//    barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
    return barButtonItem
}

}


