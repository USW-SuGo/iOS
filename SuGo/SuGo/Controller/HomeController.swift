//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

class HomeController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    var testList = ["미래", "종강", "IT", "글경", "체대", "인문"]
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        addNavigationBar()
        customRightBarButtons()
    
    }
    
    // 이 후 페이지 생성 시 함수 생성 진행 예정
    @objc func testButtonAction() {
        print("button clicked")
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
    
    @objc func findButtonClicked() {
        
        let findViewStoryboard = UIStoryboard(name: "findView", bundle: nil)
        
    }
    
    
    //MARK: Button Actions
    
    //MARK: Design Functions
    
    private func customRightBarButtons() {
        
        
        let findButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(testButtonAction),
                                                                symbolName: "customGlass")
        //customGlass
        
        let postingButton = self.navigationItem.makeSFSymbolButton(self,
                                                                action: #selector(postingButtonclicked),
                                                                symbolName: "viewMore")
        //viewMore
        
        let messageButton = self.navigationItem.makeSFSymbolButton(self,
                                               action: #selector(messageButtonClicked),
                                               symbolName: "customChat")
        //customChat
        
        let itemSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)
        itemSpace.width = 20
        
        self.navigationItem.rightBarButtonItems = [findButton, postingButton, messageButton]
    
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
        return testList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell",
                                                      for: indexPath) as! HomeCollectionViewCell
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 2 - 2
        
        let size = CGSize(width: width, height: 270)
        return size
        
    }
    
    
}

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    
}

