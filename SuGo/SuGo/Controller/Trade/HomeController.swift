//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

import Alamofire
import SwiftyJSON

class HomeController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    var homeData = [Home]()
    var testList = ["미래", "종강", "IT", "글경", "체대", "인문"]
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customLeftBarButton()
        customRightBarButtons()
        customBackButton()
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
          
        print(homeData)
//        let mapViewStoryboard = UIStoryboard(name: "MapView", bundle: nil)
//        let nextViewController =
//        mapViewStoryboard.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
//        self.present(nextViewController, animated: true, completion: nil)
        
    }
    
    //MARK: API Functions
    
    private func getMainPage(page: Int, size: Int, category: String) {
        
        AlamofireManager
            .shared
            .session
            .request(PostRouter.mainPage(page: page, size: size, category: category))
            .responseData { response in
                
                self.updateMainPage(json: JSON(response.data))
                
            }
        
    }
    
    private func updateMainPage(json: JSON) {
        
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
            
            let rawData = Home(id: json[i]["id"].intValue,
                               imageLink: images,
                               contactPlace: json[i]["contactPlace"].stringValue,
                               updatedAt: json[i]["updatedAt"].stringValue,
                               title: json[i]["title"].stringValue,
                               price: json[i]["price"].intValue,
                               nickname: json[i]["nickname"].stringValue,
                               category: json[i]["category"].stringValue)
            
            homeData.append(rawData)
            
            // need to reload - collectionView.reload()
            
        }
        
        self.collectionView.reloadData()
        
        print(homeData)
        
        
    }

    //MARK: Button Actions
    
    //MARK: Design Functions
    
    private func customLeftBarButton(){
        
        let sideMenuButton = self.navigationItem.makeSFSymbolButton(self,
                                                                    action: #selector(hamburgerButtonClicked),
                                                                    symbolName: "hambuger")
        self.navigationItem.leftBarButtonItem = sideMenuButton
        
    }
    
    // 네비게이션 바 우측 버튼 커스텀
    private func customRightBarButtons() {
            
        let mapButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(mapButtonClicked),
                                                                symbolName: "place")
        
        let postingButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(postingButtonclicked),
                                                                symbolName: "viewMore")
      
        
        let messageButton = self.navigationItem.makeSFSymbolButton(self,
                                               action: #selector(messageButtonClicked),
                                               symbolName: "customChat")
        
        self.navigationItem.rightBarButtonItems = [mapButton, postingButton, messageButton]
                
    }
    
    private func customBackButton() {
        
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButtonItem.tintColor = .darkGray
        self.navigationItem.backBarButtonItem = backButtonItem
        
    }
    
    private func customNaviagtionBar() {
        
    }
    
    private func addNavigationBar() {
        
        // Get Safe Area
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0

        // navigationBar
        let naviBar = UINavigationBar(frame: .init(x: 0,
                                                   y: statusBarHeight,
                                                   width: view.frame.width,
                                                   height: statusBarHeight))
        naviBar.isTranslucent = false
        naviBar.backgroundColor = .systemBackground

        let naviItem = UINavigationItem(title: "SUGO")
        naviItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                      target: self,
                                                      action: nil)
        naviBar.items = [naviItem]
        
        view.addSubview(naviBar)
         
    }

}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell",
                                                      for: indexPath) as! HomeCollectionViewCell
        
//        
//        if let url = URL(string: homeData[indexPath.row].imageLink[0]) {
//            
//            let imageData = try? Data(contentsOf: url)
//            let image = UIImage(data: imageData!)
//            let data = image?.jpegData(compressionQuality: 0.2)
//            let putImage = UIImage(data: data!)
//            putImage?.size.width = CGFloat(collectionView.frame.width / 2 - 0.2)
//            putImage?.size.height = 270
//            cell.image.image = UIImage(data: putImage!)
//            
//            
//        }
//        
        
       
        cell.backgroundColor = .white
        cell.placeLabel.text = "장소 : \(testList[indexPath.row])"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postViewStoryboard = UIStoryboard(name: "PostView", bundle: nil)
        let nextViewController =
        postViewStoryboard.instantiateViewController(withIdentifier: "postVC") as! PostController
        self.navigationController?.pushViewController(nextViewController, animated: true)
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
        
        print("UIScreenWidth - \(UIScreen.main.bounds.width)")
        print("collectionViewWidth - \(collectionView.frame.width)")
        print("UICell - \(width)")
        
        let size = CGSize(width: width, height: 270)
        
        return size
        
    }
    
    
}

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func layoutSubviews() {
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.borderWidth = 0.5
    }
    
}

