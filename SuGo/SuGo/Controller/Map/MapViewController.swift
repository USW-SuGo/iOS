//
//  MapViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/05.
//

import UIKit

class MapViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var mapImageView: UIImageView!
    
    //MARK: Properties
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pinchAction()
        dragAction()
        print("UIScreen Width & Height : \(UIScreen.main.bounds.width), \(UIScreen.main.bounds.height)")
        print("center X , Y : \(mapImageView.center.x), \(mapImageView.center.y)")
        // Do any additional setup after loading the view.
    }
    
    private func pinchAction() {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
        self.view.addGestureRecognizer(pinch)
        
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        let moveWidth = pinch.scale * self.mapImageView.frame.width
        let moveHeight = pinch.scale * self.mapImageView.frame.height
        
        // 핸드폰 기종 최소 비율로 축소 - > 원본
        if UIScreen.main.bounds.width > moveWidth || UIScreen.main.bounds.height > moveHeight {
        
            pinch.scale = 1
            
        // 핸드폰 화면 2.5배만큼 확대
        } else if UIScreen.main.bounds.width * 2.5 < moveWidth || UIScreen.main.bounds.height * 2.5 < moveHeight{
            
            pinch.scale = 1
            
        // 즉 1 ~ 2.5배까지 +- 가능, 범주 내에 있을 시 확대 및 축소 진행
        } else {
            
            mapImageView.transform = mapImageView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
    }
    
    private func dragAction() {
        let drag = UIPanGestureRecognizer(target: self, action: #selector(doDrag))
        drag.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(drag)
    }
    
    @objc func doDrag(_ sender: UIPanGestureRecognizer) {
        
        let transition = sender.translation(in: mapImageView)
        print("transition : \(transition)")
        var changedX = mapImageView.center.x + transition.x
        var changedY = mapImageView.center.y + transition.y
        print("changedX & Y : \(changedX), \(changedY)")
        
        if (UIScreen.main.bounds.width / 2) - 100 > changedX  {
            changedX = mapImageView.center.x
            print("if 1")
        }
        
        if (UIScreen.main.bounds.width / 2) + 100 < changedX {
            changedX = mapImageView.center.x
            print("if 2")
        }
        
        mapImageView.center = CGPoint(x: changedX, y: changedY)
        sender.setTranslation(CGPoint.zero, in: mapImageView)
        
        
    }
    
    //MARK: Button Actions
    
    //MARK: Design Functions


}
