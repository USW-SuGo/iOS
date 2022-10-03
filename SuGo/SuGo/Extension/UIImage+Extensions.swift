//
//  UIImage+Extensions.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import UIKit
import Foundation

extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        print("화면 배율 : \(UIScreen.main.scale)")
        print("origin : \(self), resize : \(renderImage)")
        
        return renderImage
    }
    
}
