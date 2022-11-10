//
//  PostController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/17.
//

import UIKit

import Alamofire
import ImageSlideshow
import SwiftyJSON

class PostController: UIViewController {

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: IBOutlets
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var sugoButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeUpdateCategoryLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    //MARK: Properties
    
    var productPostId = 0
    var productContentsDetail = ProductContentsDetail()
    // imageFiles
    var alamofireSource: [AlamofireSource] = []
    
    //MARK: Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        getPostProduct()
        designButtons()
        // Do any additional setup after loading the view.

    }
    
    private func setSlideShow() {
        
        // 자동 슬라이드
        // slideshow.slideshowInterval = 5.0
        
        // 이미지 포지션
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.systemGreen
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        slideshow.pageIndicator = pageIndicator

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        // image input
        slideshow.setImageInputs(alamofireSource)

        // page 넘기기 이벤트
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)
        
    }
    
    @objc func didTap() {
           let fullScreenController = slideshow.presentFullScreenController(from: self)
           // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
           fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
       }
    
    func decimalWon(price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
        
        return result
    }
    
    //MARK: API Functions
    
    private func getPostProduct() {
        AlamofireManager
            .shared
            .session
            .request(PostRouter.getDetailPost(productPostId: productPostId))
            .validate()
            .responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    self.updatePost(json: JSON(response.data ?? "") )
                }
                
                
            }
    }
    
    private func updatePost(json: JSON) {
        
        if json != "" {
            
            productContentsDetail.id = json["id"].intValue
            productContentsDetail.contactPlace = json["contactPlace"].stringValue
            productContentsDetail.title = json["title"].stringValue
            productContentsDetail.price = decimalWon(price: json["price"].intValue)
            productContentsDetail.nickname = json["nickname"].stringValue
            productContentsDetail.category = json["category"].stringValue
            productContentsDetail.content = json["content"].stringValue
            
            let jsonImages = json["imageLink"].stringValue
            var images = jsonImages.components(separatedBy: ", ").map({String($0)})
            
            // JSON으로 내려받을 때 stringValue로 떨어지기에, 콤마로 스플릿 후 데이터 일부 수정
            if images.count == 1 {
                images[0] = String(images[0].dropFirst())
                images[0] = String(images[0].dropLast())
            } else {
                images[0] = String(images[0].dropFirst())
                images[images.count - 1] = String(images[images.count - 1].dropLast())
            }
            
            productContentsDetail.imageLink = images
            
            let postDate = json["updatedAt"].stringValue.components(separatedBy: "T")[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDate = dateFormatter.date(from: postDate) ?? nil
            let interval = Date().timeIntervalSince(startDate ?? Date())
            let intervalDays = Int((interval) / 86400)
            var updatedAt = ""
            
            if intervalDays < 1 {
                updatedAt = "오늘"
            } else if intervalDays == 1 {
                updatedAt = "어제"
            } else if intervalDays < 7 {
                updatedAt = "\(intervalDays)일 전"
            } else if intervalDays < 30 {
                updatedAt = "\(intervalDays / 7)주 전"
            } else {
                updatedAt = "\(intervalDays / 30)달 전"
            }
            
            productContentsDetail.updatedAt = updatedAt
            
            for i in 0..<productContentsDetail.imageLink.count {
                alamofireSource.append(AlamofireSource(urlString: productContentsDetail.imageLink[i])!)
            }
            
            setSlideShow()
            updateDesign()
            
        }
    }
    
    //MARK: Button Actions
    
    //MARK: Design Functions
    
    private func updateDesign() {
        
        titleLabel.text = productContentsDetail.title
        placeUpdateCategoryLabel.text = "\(productContentsDetail.contactPlace) | \(productContentsDetail.updatedAt) | \(productContentsDetail.category)"
        nicknameLabel.text = productContentsDetail.nickname
        priceLabel.text = productContentsDetail.price
        contentLabel.text = productContentsDetail.content
        
    }

    private func designButtons() {
        sugoButton.layer.cornerRadius = 6.0
        sugoButton.layer.borderWidth = 1.0
        sugoButton.layer.borderColor = UIColor.white.cgColor
    }
    
    

}

extension PostController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
