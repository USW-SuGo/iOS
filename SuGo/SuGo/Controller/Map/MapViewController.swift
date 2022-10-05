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
        // Do any additional setup after loading the view.
    }
    
    private func pinchAction() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
        self.view.addGestureRecognizer(pinch)
        
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        let moveWidth = pinch.scale * self.mapImageView.frame.width
        let moveHeight = pinch.scale * self.mapImageView.frame.height
        if UIScreen.main.bounds.width > moveWidth || UIScreen.main.bounds.height > moveHeight {
            
            pinch.scale = 1
            
//        } else if UIScreen.main.bounds.width * 3 < moveWidth || UIScreen.main.bounds.height * 3 < moveHeight {
//
//            pinch.scale = 1
//
        }
        else {
            mapImageView.transform = mapImageView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
        }
        print("moveWidth & Height - \(moveWidth), \(moveHeight)")
        print("pinchScale - \(pinch.scale)")
        
        pinch.scale = 1
    }
    
    private func dragAction() {
        let drag = UIPanGestureRecognizer(target: self, action: #selector(doDrag))
        drag.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(drag)
    }
    
    @objc func doDrag(_ sender: UIPanGestureRecognizer) {
        
        let transition = sender.translation(in: mapImageView)
        let changedX = mapImageView.center.x + transition.x
        let changedY = mapImageView.center.y + transition.y
        mapImageView.center = CGPoint(x: changedX, y: changedY)
        sender.setTranslation(CGPoint.zero, in: mapImageView)
        
        
    }
    
    //MARK: Button Actions
    
    //MARK: Design Functions


}
