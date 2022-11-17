//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

import Alamofire
import MaterialComponents
import SwiftyJSON
import KeychainSwift
import Kingfisher

class HomeController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noSearchResultView: UIView!
    @IBOutlet weak var noSearchResultLabel: UILabel!
    @IBOutlet weak var showHomeButton: UIButton!
    
    //MARK: Properties
    
  let keychain = KeychainSwift()
  var homeProductContents = [ProductContents]()
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let categorySelect = CategorySelect.shared
  var page = 0
  var lastPage = false
  private lazy var refresh: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(callRefresh), for: .valueChanged)
    return refreshControl
  }()
    
    //MARK: Life Cycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    print("Home - viewDidLoad")
    collectionView.refreshControl = refresh
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(homeBottomDismissObserver),
                                           name: NSNotification.Name("homeBottomDismiss"),
                                           object: nil)
    customLeftBarButton()
    customRightBarButtons()
    customBackButton()
    searchViewDesign()
    print(keychain.get("AccessToken"))
    
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("Home - viewWillAppear")
    if searchTextField.text == "" {
      page = 0
      lastPage = false
      callGetMainPage()
      customCategoryButton(category: categorySelect.homeCategory)
    }
  }
    
  //MARK: Functions
  
  @objc func callRefresh() {
    collectionView.refreshControl?.beginRefreshing()
    page = 0
    lastPage = false
    callGetMainPage()
    customCategoryButton(category: categorySelect.homeCategory)
    collectionView.refreshControl?.endRefreshing()
  }
  
    
    // modal view dismiss catch use observer
  @objc func homeBottomDismissObserver(_ notification: Notification){
    DispatchQueue.main.async {
      self.page = 0
      self.lastPage = false
      self.searchTextField.text = ""
      self.callGetMainPage()
      self.customCategoryButton(category: self.categorySelect.homeCategory)
    }
  }
  
  //@objc functions for navigation bar buttons
  @objc func sideMenuButtonClicked() {
    let sideMenuViewStoryboard = UIStoryboard(name: "SideMenuView", bundle: nil)
    let sideMenuViewController =
    sideMenuViewStoryboard.instantiateViewController(withIdentifier: "sideVC") as! SideMenuController
    let sideMenu = SideMenuNavController(rootViewController: sideMenuViewController)
    present(sideMenu, animated: true, completion: nil)
  }
    
  // 1. message 2. posting 3. map
  @objc func messageButtonClicked() {
    let messageListView = UIStoryboard(name: "MessageListView", bundle: nil)
    let messageListNavigationController = messageListView.instantiateViewController(withIdentifier: "messageListNavigationVC") as! UINavigationController
    messageListNavigationController.modalPresentationStyle = .fullScreen
    present(messageListNavigationController, animated: true)
  }

  @objc func postingButtonclicked() {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.myPage(page: 0, size: 10))
      .validate()
      .responseJSON { response in
        if response.response?.statusCode == 200 {
          let postingView = UIStoryboard(name: "PostingView", bundle: nil)
          guard let postingNavigationController = postingView.instantiateViewController(withIdentifier: "postingNavigationVC") as? UINavigationController else { return }
          postingNavigationController.modalPresentationStyle = .fullScreen
          self.present(postingNavigationController, animated: true)
        } else {
          self.keychain.clear()
          self.presentViewController(storyboard: "LoginView", identifier: "loginVC", fullScreen: true)
      }
    }
  }
    
  @objc func mapButtonClicked() {
      presentViewController(storyboard: "MapView", identifier: "mapVC", fullScreen: false)
  }
  
  private func pushViewController(storyboard: String, identifier: String) {
      let nextStoryboard = UIStoryboard(name: storyboard, bundle: nil)
      let nextViewController = nextStoryboard.instantiateViewController(withIdentifier: identifier)
      self.navigationController?.pushViewController(nextViewController, animated: true)
  }
  
  private func presentViewController(storyboard: String,
                                     identifier: String,
                                     fullScreen: Bool) {
      let nextStoryboard = UIStoryboard(name: storyboard, bundle: nil)
      let nextViewController = nextStoryboard.instantiateViewController(withIdentifier: identifier)
      if fullScreen {
          nextViewController.modalPresentationStyle = .fullScreen
      }
      self.present(nextViewController, animated: true)
  }
    
  //MARK: API Functions
  
  private func callGetMainPage() {
    if page == 0 {
      homeProductContents.removeAll()
    }
    
    if categorySelect.homeCategory == "전체" {
        getMainPage(page: page, size: 10, category: "")
    } else {
        getMainPage(page: page, size: 10, category: categorySelect.homeCategory)
    }
  }
  
  private func getMainPage(page: Int, size: Int, category: String) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.mainPage(page: page,
                                   size: size,
                                   category: category))
      .responseData { response in
        guard let data = response.data else { return }
        if JSON(data).count < 10 {
          self.lastPage = true
        }
        self.updateMainPage(json: JSON(data))
    }
  }
  
  private func updateMainPage(json: JSON) {
      noSearchResultView.isHidden = true
      jsonToCollectionViewData(json: json)
  }
    
  private func getSearchData(searchData: String, category: String) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.searchContent(value: searchData,
                                        category: category))
      .validate()
      .responseData { response in
              
        if response.response?.statusCode == 200 {
            self.updateSearchPage(json: JSON(response.data ?? ""),
                                  searchData: searchData)
        } else {
            self.keychain.clear()
            self.presentViewController(storyboard: "LoginView", identifier: "loginVC", fullScreen: true)
      }
    }
  }
    
  private func updateSearchPage(json: JSON, searchData: String) {
    if json.count > 0 {
      noSearchResultView.isHidden = true
      jsonToCollectionViewData(json: json)
    } else {
      noSearchResultViewDesign(searchData: searchData)
    }
  }
  
  // 이 부분을 모델로 뺄 수 없을지 고민해보자.
  private func jsonToCollectionViewData(json: JSON) {
    for i in 0..<json.count {
      let jsonImages = json[i]["imageLink"].stringValue
      var images = jsonImages.components(separatedBy: ", ").map({String($0)})
      
      // when get data it is stringValue, so split use ','
      if images.count == 1 {
          images[0] = String(images[0].dropFirst())
          images[0] = String(images[0].dropLast())
      } else {
          images[0] = String(images[0].dropFirst())
          images[images.count - 1] = String(images[images.count - 1].dropLast())
      }
          
          // localDateTime to yyyy-mm-dd to 오늘 / 어제 / n일 전 등
      let postDate = json[i]["updatedAt"].stringValue.components(separatedBy: "T")[0]
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
          
      let getData = ProductContents(productIndex: json[i]["id"].intValue,
                                    imageLink: images,
                                    contactPlace: json[i]["contactPlace"].stringValue,
                                    updatedAt: updatedAt,
                                    title: json[i]["title"].stringValue,
                                    price: decimalWon(price: json[i]["price"].intValue),
                                    nickname: json[i]["nickname"].stringValue,
                                    category: json[i]["category"].stringValue,
                                    status: json[i]["status"].boolValue)
      homeProductContents.append(getData)
      }
    self.collectionView.reloadData()
  }
    
    // call viewWillAppear or when user choose category
   
    
    // it will be infinite scroll
    
  func decimalWon(price: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
    
    return result
  }

  //MARK: Button Actions
  
  @IBAction func showHomeButtonClicked(_ sender: Any) {
    page = 0
    callGetMainPage()
    customCategoryButton(category: categorySelect.homeCategory)
//        noSearchResultView.isHidden = true
//        collectionView.reloadData()
  }
    
  @IBAction func searchButtonclicked(_ sender: Any) {
    let searchData = searchTextField.text ?? ""
    var category = categorySelect.homeCategory
    if category == "전체" {
        category = ""
    }
    homeProductContents.removeAll()
    getSearchData(searchData: searchData, category: category)
  }
    
    @IBAction func categoryButtonClicked(_ sender: Any) {
        let bottomSheetView = UIStoryboard(name: "HomeBottomSheetView", bundle: nil)
        let nextVC = bottomSheetView.instantiateViewController(withIdentifier: "homeBottomSheetVC") as! HomeBottomSheetController
        let bottomSheet = MDCBottomSheetController(contentViewController: nextVC)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 330
        bottomSheet.dismissOnDraggingDownSheet = true
        present(bottomSheet, animated: true)
    }
    
    //MARK: Design Functions
    
    // when user choose category
    private func customCategoryButton(category: String) {
        if category == "" {
            categoryButton.setTitle("카테고리", for: .normal)
        } else {
            categoryButton.setTitle(category, for: .normal)
        }
    }
    
    // navigation bar's buttons custom
    private func customLeftBarButton() {
        let sideMenuButton = self.navigationItem.makeSFSymbolButton(self,
                                                                    action: #selector(sideMenuButtonClicked),
                                                                    symbolName: "sidebar.left")
        self.navigationItem.leftBarButtonItem = sideMenuButton
    }
    
    private func customRightBarButtons() {
        let mapButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(mapButtonClicked),
                                                                symbolName: "mappin.and.ellipse")
        let postingButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(postingButtonclicked),
                                                                symbolName: "plus")
        let messageButton = self.navigationItem.makeSFSymbolButton(self,
                                               action: #selector(messageButtonClicked),
                                               symbolName: "ellipsis.message")
        self.navigationItem.rightBarButtonItems = [mapButton, postingButton, messageButton]
    }
    
    private func customBackButton() {
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButtonItem.tintColor = .darkGray
        self.navigationItem.backBarButtonItem = backButtonItem
    }
    
    private func searchViewDesign() {
        searchView.layer.cornerRadius = 10.0
        searchView.layer.borderWidth = 0.5
        searchView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func noSearchResultViewDesign(searchData: String) {
        noSearchResultView.isHidden = false
        noSearchResultLabel.text = "' \(searchData) '"
        
        showHomeButton.layer.cornerRadius = 8.0
        showHomeButton.layer.borderColor = UIColor.white.cgColor
        showHomeButton.layer.borderWidth = 0.2
    }
    
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let lastIndex = homeProductContents.count - 3
    if indexPath.row == lastIndex {
      page += 1
      if !lastPage {
        callGetMainPage()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return homeProductContents.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell",
                                                  for: indexPath) as! HomeCollectionViewCell
    if homeProductContents.count > 0 {
      if let url = URL(string: homeProductContents[indexPath.row].imageLink[0]) {
//        let processor = DownsamplingImageProcessor(size: CGSize(width: cell.image.frame.width,
//                                                                  height: cell.image.frame.width * 1.33))
        cell.image.kf.indicatorType = .activity
        cell.image.kf.setImage(with: url,
                               placeholder: nil,
                               options: [
                                .transition(.fade(0.1)),
//                                .processor(processor),
                                .cacheOriginalImage
                                    ],
                               progressBlock: nil)
        
        }
      cell.image.contentMode = .scaleAspectFill
      cell.backgroundColor = .white
      cell.placeUpdateCategoryLabel.text =
      "\(homeProductContents[indexPath.row].contactPlace) | \(homeProductContents[indexPath.row].updatedAt) | \(homeProductContents[indexPath.row].category)"
      cell.nicknameLabel.text = "\(homeProductContents[indexPath.row].nickname)"
      cell.priceLabel.text = "\(homeProductContents[indexPath.row].price)"
      cell.priceLabel.textColor = colorLiteralGreen
      cell.titleLabel.text = "\(homeProductContents[indexPath.row].title)"
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      AlamofireManager
        .shared
        .session
        .request(PostRouter.getDetailPost(productPostId: homeProductContents[indexPath.row].productIndex))
        .validate()
        .responseJSON { response in
          // if users have token and refreshToken still alive
          print(JSON(response.data ?? ""))
        if response.response?.statusCode == 200 {
            let postViewStoryboard = UIStoryboard(name: "PostView", bundle: nil)
            let nextViewController =
            postViewStoryboard.instantiateViewController(withIdentifier: "postVC") as! PostController
            nextViewController.productPostId = self.homeProductContents[indexPath.row].productIndex
            self.navigationController?.pushViewController(nextViewController, animated: true)
        // else show loginPage
        } else {
            self.keychain.clear()
            self.presentViewController(storyboard: "LoginView", identifier: "loginVC", fullScreen: false)
        }
      }
    }
}

extension HomeController: UICollectionViewDelegateFlowLayout{
    
  // top & down
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  // left & right
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.frame.width / 2 - 1
    let size = CGSize(width: width, height: 330)
    return size
  }

}

class HomeCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet weak var image: UIImageView!

  let placeUpdateCategoryLabel: UILabel = {
    let placeUpdateCategoryLabel = UILabel()
    placeUpdateCategoryLabel.text = "temp"
    placeUpdateCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
    placeUpdateCategoryLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
    placeUpdateCategoryLabel.sizeToFit()
    return placeUpdateCategoryLabel
  }()
  
  let titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.text = "temp"
    titleLabel.font = UIFont(name: "Pretendard-Medium", size: 16)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    return titleLabel
  }()
  
  let priceLabel: UILabel = {
    let priceLabel = UILabel()
    priceLabel.text = "temp"
    priceLabel.font = UIFont(name: "Pretendard-Black", size: 15)
    priceLabel.translatesAutoresizingMaskIntoConstraints = false
    return priceLabel
  }()
  
  let nicknameLabel: UILabel = {
    let nicknameLabel = UILabel()
    nicknameLabel.text = "font"
    nicknameLabel.font = UIFont(name: "Pretendard-Light", size: 10)
    nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
    return nicknameLabel
  }()
  
  override func layoutSubviews() {
    contentView.layer.borderColor = UIColor.white.cgColor
    contentView.layer.borderWidth = 0.2
    addContentView()
    autoLayoutCells()
  }
  
  func addContentView() {
    contentView.addSubview(placeUpdateCategoryLabel)
    contentView.addSubview(titleLabel)
    contentView.addSubview(priceLabel)
    contentView.addSubview(nicknameLabel)
  }
    
  func autoLayoutCells() {
    image.translatesAutoresizingMaskIntoConstraints = false
    image.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    image.heightAnchor.constraint(equalToConstant: 200).isActive = true
    image.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
      
    placeUpdateCategoryLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
    placeUpdateCategoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    placeUpdateCategoryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

    titleLabel.topAnchor.constraint(equalTo: placeUpdateCategoryLabel.bottomAnchor, constant: 3).isActive = true
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    
    nicknameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
    nicknameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
    nicknameLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
    
    priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18).isActive = true
    priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    priceLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
  }
}

