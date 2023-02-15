//
//  PostController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/17.
//

import UIKit

import Alamofire
import ImageSlideshow
import KeychainSwift
import SwiftyJSON

// 리펙토링

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
  @IBOutlet weak var contentView: UILabel!
  @IBOutlet weak var likeButton: UIButton!
  
  //MARK: Properties
    
  var productPostId = 0
  var productContentsDetail = ProductContentsDetail()
  var alamofireSource: [AlamofireSource] = []
  var indexDelegate: MessageRoomIndex?
    
  //MARK: Life Cycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    customBackButton()
    getPostProduct()
    getMyIndex()
    designButtons()
  }
  
  //MARK: Functions
    
  private func setSlideShow() {
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
     fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium,
                                                                                 color: nil)
   }
    
  //MARK: API Functions
  
  // user identifier -> NullPointerException
  // 현재 유저 자신의 인덱스를 받아올 수 없음.
  
  private func getMyIndex() {
    let url = API.BASE_URL + "/user/identifier"
    guard let accessToken = KeychainSwift().get("AccessToken") else { return }
    let header: HTTPHeaders = ["Authorization" : accessToken]
    print(accessToken)
    
    AF.request(url,
               method: .get,
               encoding: URLEncoding.default,
               headers: header,
               interceptor: BaseInterceptor()).validate().response { response in
      guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
      guard let data = response.data else { return }
      self.productContentsDetail.myIndex = JSON(data)["userId"].intValue
      print(self.productContentsDetail)
    }
  }
    
  private func getPostProduct() {
      AlamofireManager
          .shared
          .session
          .request(PostRouter.getDetailPost(productIndex: productPostId))
          .validate()
          .response { response in
            guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
            self.updatePost(json: JSON(response.data ?? "") )
    }
  }
    
//  {"productPostId":190,"writerId":32,"imageLink":"https://diger-usw-sugo-s3.s3.ap-northeast-2.amazonaws.com/post-resources/190/57FBAF52-F84E-4637-8A83-292B5210B49F.jpeg, https://diger-usw-sugo-s3.s3.ap-northeast-2.amazonaws.com/post-resources/190/847D9446-63FC-4100-9D17-2651839FEE64.jpeg, https://diger-usw-sugo-s3.s3.ap-northeast-2.amazonaws.com/post-resources/190/51EA695B-E1F5-4FE5-B696-CF8367EC0750.jpeg","contactPlace":"체대","updatedAt":"2023-02-08T17:40:11","title":"test33333차","content":"제발될제발되라제발되라","price":123131312,"nickname":"정보보호학과-1","category":"서적","status":true,"userLikeStatus":false}

//  {"productPostId":139,"writerId":32,"imageLink":"https://s3.ap-northeast-2.amazonaws.com/diger-usw-sugo-s3/post-resources/139/010101010010","contactPlace":"IT","updatedAt":"2023-02-06T00:15:08","title":"01010101001","content":"ㅂ디ㅏㅂㅈ드ㅏㅣㅂㄷ즤ㅏㅂㅈ듸ㅏㅂ","price":230139201,"nickname":"정보보호학과-1","category":"전자기기","status":true,"userLikeStatus":false}
//
  
    private func updatePost(json: JSON) {
      guard json != "" else {
        self.navigationController?.popViewController(animated: true)
        return }
      productContentsDetail = ProductContentsDetail(json: json)
      for i in 0..<productContentsDetail.imageLink.count {
        let imageLink = productContentsDetail.imageLink[i]
        guard let image = AlamofireSource(urlString: imageLink) else {
          print(imageLink)
          return }
        alamofireSource.append(image)
      }
      setSlideShow()
      updateDesign()
    }
    
  //MARK: Button Actions
  
  @IBAction func userInfoButtonClicked(_ sender: Any) {
    let userInfoView = UIStoryboard(name: "UserInfoView", bundle: nil)
    guard let userInfoController = userInfoView.instantiateViewController(withIdentifier: "userInfoVC") as? UserInfoController else { return }
    userInfoController.userId = productContentsDetail.userIndex
    self.navigationController?.pushViewController(userInfoController, animated: true)
  }
  
  @IBAction func likeButtonClicked(_ sender: Any) {
    let url = "https://api.sugo-diger.com/like"
    let parameter = ["productPostId" : productContentsDetail.productIndex]
    guard let accessToken = KeychainSwift().get("AccessToken") else { return }
    let header: HTTPHeaders = ["Authorization" : accessToken]
    
    AF.request(url,
               method: .post,
               parameters: parameter,
               encoding: JSONEncoding.default,
               headers: header,
               interceptor: BaseInterceptor()).validate().response { response in
      guard let statusCode = response.response?.statusCode, statusCode == 200 else {
        self.customAlert(title: "자신의 게시물이에요!", message: "자신의 게시물은 좋아요할 수 없어요!")
        return }
      guard let responseData = response.data else { return }
      
      JSON(responseData)["Like"].boolValue ?
      self.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal) :
      self.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
  }
  
  // 서버에서 쪽지방 삭제 기능 구현 이후 테스트 가능
  @IBAction func sugoButtonClicked(_ sender: Any) {
    AlamofireManager
      .shared
      .session
      .request(MessageRouter.makeMessageRoom(opponentIndex: productContentsDetail.userIndex,
                                             productIndex: productContentsDetail.productIndex))
      .validate()
      .response { response in
        
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          print(JSON(response.data))
          return }
        guard let data = response.data else { return }
        print(JSON(data))
        // 수고하기 버튼 클릭 후 바로 쪽지방으로 연결, 쪽지 데이터 없을 경우 공지사항같은거 만들어줘야 함
        let messageRoomView = UIStoryboard(name: "MessageRoomView", bundle: nil)
        guard let messageRoomController = messageRoomView.instantiateViewController(withIdentifier: "messageRoomVC") as? MessageRoomController else { return }
        self.indexDelegate?.getIndex(roomIndex: JSON(data)["noteId"].intValue,
                                     myIndex: self.productContentsDetail.myIndex,
                                     oppositeIndex: self.productContentsDetail.userIndex)
        self.navigationController?.pushViewController(messageRoomController, animated: true)
      }
  }
  
  //MARK: Design Functions
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
    
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
  private func updateDesign() {
    titleLabel.text = productContentsDetail.title
    placeUpdateCategoryLabel.text = "\(productContentsDetail.contactPlace) | \(productContentsDetail.updatedAt) | \(productContentsDetail.category)"
    nicknameLabel.text = productContentsDetail.nickname
    priceLabel.text = productContentsDetail.price
    contentView.text = productContentsDetail.content
    productContentsDetail.userLikeStatus ?
    likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal) :
    likeButton.setImage(UIImage(systemName: "heart"),for: .normal)
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

