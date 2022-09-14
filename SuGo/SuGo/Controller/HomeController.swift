//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

class HomeController: UIViewController {

    //MARK: IBOutlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    var testList = ["미래", "종강", "IT", "글경", "체대", "인문"]
    
    //MARK: Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // addNavigationBar()
        
    }
    
    //MARK: Button Action
    
    //MARK: Design
    
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

        let naviItem = UINavigationItem(title: "title")
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
        
        print(width)
        let size = CGSize(width: width, height: width + 100)
        return size
        
    }
    
}
class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    
}

