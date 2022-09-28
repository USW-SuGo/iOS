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
        button.setImage(UIImage(named: symbolName), for: .normal)
        // action은 objc 함수로 define -> if 내가 필요 시
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .black
            
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
            
        return barButtonItem
    }
}

