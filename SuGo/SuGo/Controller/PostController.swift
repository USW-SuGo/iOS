//
//  PostController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/17.
//

import UIKit

import ImageSlideshow

class PostController: UIViewController {

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: IBOutlets
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    //MARK: Properties
    
    let localSource = [BundleImageSource(imageString: "img1"), BundleImageSource(imageString: "img2"), BundleImageSource(imageString: "img3"), BundleImageSource(imageString: "img4")]
        let afNetworkingSource = [AFURLSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AFURLSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AFURLSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
        let alamofireSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
        let sdWebImageSource = [SDWebImageSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, SDWebImageSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, SDWebImageSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
        let kingfisherSource = [AFURLSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AFURLSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AFURLSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
        pageIndicator.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageIndicator

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(localSource)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)

        // Do any additional setup after loading the view.
    }
    
    @objc func didTap() {
           let fullScreenController = slideshow.presentFullScreenController(from: self)
           // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
           fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
       }
    
    //MARK: Button Actions
    
    //MARK: Design Functions

}

extension PostController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
