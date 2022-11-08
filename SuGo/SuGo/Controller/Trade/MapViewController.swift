//
//  MapViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/05.
//

import UIKit

import ImageScrollView

class MapViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    @IBOutlet weak var mapImageView: UIImageView!
    
    //MARK: Properties
    
    var moveWidth: CGFloat = 0
    var moveHeight: CGFloat = 0
    var lastWidth: CGFloat = 0
    
    var initialCenter: CGPoint = CGPoint(x: 0, y: 0)
    var enlargementCheck: Bool = false
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initialCenter = CGPoint(x: mapImageView.center.x, y: mapImageView.center.y)
        imageScrollViewSetUp()
//        print(initialCenter)
//        pinchAction()
//        dragAction()
//
//        print("UIScreen Width & Height : \(UIScreen.main.bounds.width), \(UIScreen.main.bounds.height)")
//        print("center X , Y : \(mapImageView.center.x), \(mapImageView.center.y)")
        // Do any additional setup after loading the view.
    }
    
    private func imageScrollViewSetUp() {
        //campusmap_img
        imageScrollView.setup()
        let campusImage = UIImage(named: "campusmap_img.jpeg")!
        imageScrollView.display(image: campusImage)
        imageScrollView.imageContentMode = .aspectFit
    }
    
    private func pinchAction() {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
        self.view.addGestureRecognizer(pinch)
        
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        moveWidth = pinch.scale * self.mapImageView.frame.width
        moveHeight = pinch.scale * self.mapImageView.frame.height
        // 390 * 844
//        print("moveWidth - \(moveWidth)")
//        print("moveHeight - \(moveHeight)")
        print("last - move : \(lastWidth) - \(moveWidth)")

        // 핸드폰 기종 최소 비율로 축소 - > 원본
        if UIScreen.main.bounds.width > moveWidth || UIScreen.main.bounds.height > moveHeight {
        
            pinch.scale = 1
            
        // 핸드폰 화면 2.5배만큼 확대
        } else if UIScreen.main.bounds.width * 2.5 < moveWidth || UIScreen.main.bounds.height * 2.5 < moveHeight{
            
            pinch.scale = 1
            
        // 즉 1 ~ 2.5배까지 +- 가능, 범주 내에 있을 시 확대 및 축소 진행
        } else if lastWidth <= 450 && lastWidth > moveWidth {
            
            mapImageView.transform = .identity
            mapImageView.center = initialCenter
            print("identity called")
            lastWidth = 0
            
        } else {
            
            mapImageView.transform = mapImageView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
            lastWidth = moveWidth
            
            
        }
        
       
        
        
    }
    
//    private func dragAction() {
//        let drag = UIPanGestureRecognizer(target: self, action: #selector(doDrag))
//        drag.maximumNumberOfTouches = 2
//        self.view.addGestureRecognizer(drag)
//    }
//
//    @objc func doDrag(_ sender: UIPanGestureRecognizer) {
//
//        let transition = sender.translation(in: mapImageView)
////        print("transition : \(transition)")
//
////        print("UIScreen Width & Height : \(UIScreen.main.bounds.width), \(UIScreen.main.bounds.height)")
////        print("center X , Y : \(mapImageView.center.x), \(mapImageView.center.y)")
//
//        if sender.state == .began {
//            initialCenter = mapImageView.center
//        }
//
//        if sender.state != .cancelled {
//
//            var changedX = mapImageView.center.x + transition.x
//            var changedY = mapImageView.center.y + transition.y
////            print("changedX & Y : \(changedX), \(changedY)")
//
//            let maxX = mapImageView.frame.width * 0.5
////            let minX = mapSuperView.bounds.width - mapImageView.frame.width * 0.5
//
//            changedX = max(min(changedX, maxX), minX)
//
////            let maxY = mapImageView.frame.height * 0.4
////            let minY = mapSuperView.bounds.height - mapImageView.frame.height * 0.4
////
////            changedY = max(min(changedY, maxY), minY)
//
//            mapImageView.center = CGPoint(x: changedX, y: mapImageView.center.y)
//            sender.setTranslation(CGPoint.zero, in: mapImageView)
//
//        } else {
//            mapImageView.center = initialCenter
//        }
//
////        if enlargementCheck { // 유저가 지도 확대시
////
////            print("enlargement : true")
////
////            if (UIScreen.main.bounds.width / 2) - 100 > changedX  {
////                changedX = mapImageView.center.x
////            }
////
////            if (UIScreen.main.bounds.width / 2) + 100 < changedX {
////                changedX = mapImageView.center.x
////            }
////
////        } else { // 확대되지 않았을 경우 X축 제한
////
////            print("enlargement : false")
////
////            if (UIScreen.main.bounds.width / 2) - 100 > changedX  {
////                changedX = mapImageView.center.x
////            }
////
////            if (UIScreen.main.bounds.width / 2) + 100 < changedX {
////                changedX = mapImageView.center.x
////            }
////
////        }
//
//
//
//    }
    
    //MARK: Button Actions
    
    //MARK: Design Functions


}

extension MapViewController: ImageScrollViewDelegate {
    
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {

        print("Did Change Oritentation")

    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("Did End Zooming")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Did Scroll")
    }
    
    
}

