//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

import Alamofire
import SwiftyJSON
import KeychainSwift
import Kingfisher

class HomeController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    let keychain = KeychainSwift()
    var homeProductContents = [ProductContents]()
    var testList = ["미래", "종강", "IT", "글경", "체대", "인문"]
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customLeftBarButton()
        customRightBarButtons()
        customBackButton()
        searchViewDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMainPage(page: 0, size: 10, category: "")
    }
    
    // 이 후 페이지 생성 시 함수 생성 진행 예정
    @objc func testButtonAction() {
        print("button clicked")
    }
    
    @objc func hamburgerButtonClicked() {
        
        let sideMenuViewStoryboard = UIStoryboard(name: "SideMenuView", bundle: nil)
        let sideMenuViewController =
        sideMenuViewStoryboard.instantiateViewController(withIdentifier: "sideVC") as! SideMenuController
        let sideMenu = SideMenuNavController(rootViewController: sideMenuViewController)
        self.present(sideMenu, animated: true, completion: nil)
        
    }
    
    // 네비게이션 바 함수 1. 메세지 2. 게시물 3. 검색
    
    @objc func messageButtonClicked() {
        
        let chatingListViewStoryboard = UIStoryboard(name: "ChatingListView", bundle: nil)
        let nextViewController =
        chatingListViewStoryboard.instantiateViewController(withIdentifier: "chatinglistVC") as! ChatingListController
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

    @objc func postingButtonclicked() {
        
        let postingViewStoryboard = UIStoryboard(name: "PostingView", bundle: nil)
        let nextViewController =
        postingViewStoryboard.instantiateViewController(withIdentifier: "postingVC") as! PostingController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true, completion: nil)
        
    }
    
    @objc func mapButtonClicked() {
          
        let mapViewStoryboard = UIStoryboard(name: "MapView", bundle: nil)
        let nextViewController =
        mapViewStoryboard.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
        self.present(nextViewController, animated: true, completion: nil)
        
    }
    
    //MARK: API Functions
    
    private func getMainPage(page: Int, size: Int, category: String) {
        AlamofireManager
            .shared
            .session
            .request(PostRouter.mainPage(page: page, size: size, category: category))
            .responseData { response in
                
                self.updateHome(json: JSON(response.data ?? ""))
                
            }
        
    }
    
    private func updateHome(json: JSON) {
        homeProductContents.removeAll()
        for i in 0..<json.count {
            
            let jsonImages = json[i]["imageLink"].stringValue
            var images = jsonImages.components(separatedBy: ", ").map({String($0)})
            
            // JSON으로 내려받을 때 stringValue로 떨어지기에, 콤마로 스플릿 후 데이터 일부 수정
            if images.count == 1 {
                
                images[0] = String(images[0].dropFirst())
                images[0] = String(images[0].dropLast())
                
            } else {
                
                images[0] = String(images[0].dropFirst())
                images[images.count - 1] = String(images[images.count - 1].dropLast())
                
            }
            
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
                
            } else { // 주 단위 추가 필요
                
                updatedAt = "\(intervalDays / 30)달 전"
                
            }
            
            print(json[i]["price"].intValue)
            
            let rawData = ProductContents(id: json[i]["id"].intValue,
                               imageLink: images,
                               contactPlace: json[i]["contactPlace"].stringValue,
                               updatedAt: updatedAt,
                               title: json[i]["title"].stringValue,
                               price: decimalWon(price: json[i]["price"].intValue),
                               nickname: json[i]["nickname"].stringValue,
                               category: json[i]["category"].stringValue)
            
            homeProductContents.append(rawData)
            
            // need to reload - collectionView.reload()
            
        }
        
        self.collectionView.reloadData()
        
    }
    
    func decimalWon(price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
        
        return result
    }

    //MARK: Button Actions
    
    //MARK: Design Functions
    
    private func customLeftBarButton(){
        
        let sideMenuButton = self.navigationItem.makeSFSymbolButton(self,
                                                                    action: #selector(hamburgerButtonClicked),
                                                                    symbolName: "sidebar.left")
        self.navigationItem.leftBarButtonItem = sideMenuButton
        
    }
    
    // 네비게이션 바 우측 버튼 커스텀
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
    
    private func customNaviagtionBar() {
        
    }
    
    private func searchViewDesign() {
        
        searchView.layer.cornerRadius = 10.0
        searchView.layer.borderWidth = 0.5
        searchView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    
//    private func addNavigationBar() {
//
//        // Get Safe Area
//        var statusBarHeight: CGFloat = 0
//        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
//
//        // navigationBar
//        let naviBar = UINavigationBar(frame: .init(x: 0,
//                                                   y: statusBarHeight,
//                                                   width: view.frame.width,
//                                                   height: statusBarHeight))
//        naviBar.isTranslucent = false
//        naviBar.backgroundColor = .systemBackground
//
//        let naviItem = UINavigationItem(title: "SUGO")
//        naviItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
//                                                      target: self,
//                                                      action: nil)
//        naviBar.items = [naviItem]
//
//        view.addSubview(naviBar)
//
//    }

}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeProductContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell",
                                                      for: indexPath) as! HomeCollectionViewCell
        
        if let url = URL(string: homeProductContents[indexPath.row].imageLink[0]) {
            
            let processor = DownsamplingImageProcessor(size: CGSize(width: cell.image.frame.width,
                                                                    height: cell.image.frame.width * 1.33))
            
            cell.image.kf.indicatorType = .activity
            cell.image.kf.setImage(with: url,
                                   placeholder: nil,
                                   options: [
                                    .transition(.fade(0.1)),
                                    .processor(processor),
                                    .cacheOriginalImage
                                        ],
                                   progressBlock: nil)
            }
        
        cell.backgroundColor = .white
        cell.placeUpdateCategoryLabel.text =
        "\(homeProductContents[indexPath.row].contactPlace) | \(homeProductContents[indexPath.row].updatedAt) | \(homeProductContents[indexPath.row].category)"
        cell.nicknameLabel.text = "\(homeProductContents[indexPath.row].nickname)"
        cell.priceLabel.text = "\(homeProductContents[indexPath.row].price)"
        cell.priceLabel.textColor = colorLiteralGreen
        cell.titleLabel.text = "\(homeProductContents[indexPath.row].title)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if keychain.get("AccessToken") != nil {
            
            let postViewStoryboard = UIStoryboard(name: "PostView", bundle: nil)
            let nextViewController =
            postViewStoryboard.instantiateViewController(withIdentifier: "postVC") as! PostController
            nextViewController.productPostId = homeProductContents[indexPath.row].id
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        } else {
            
            let loginViewStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
            let nextViewController =
            loginViewStoryboard.instantiateViewController(withIdentifier: "loginVC") as! LoginController
            self.present(nextViewController, animated: true)
            
        }
        
    }
    
}

extension HomeController: UICollectionViewDelegateFlowLayout{
    
    // 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // 좌우 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 2 - 0.2
        
//        print("UIScreenWidth - \(UIScreen.main.bounds.width)")
//        print("collectionViewWidth - \(collectionView.frame.width)")
//        print("UICell - \(width)")
        let size = CGSize(width: width, height: width * 1.67)
        
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
        contentView.layer.borderColor = UIColor.systemGray2.cgColor
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
        image.heightAnchor.constraint(equalToConstant: image.frame.width * 1.33).isActive = true
//        print("width, height - \(image.frame.width), \(image.frame.width * 1.77)")
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
        
        
        priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        
        
    }
    
}

