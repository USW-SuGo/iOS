//
//  ViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/08.
//

import UIKit

class ViewController: UIViewController {

    //MARK: IBOutlet
    
    //MARK: Properties
    
    //MARK: Function
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Button Action
    
    //MARK: Design
    
    private func addNavigationBar() {
        
        // Get Safe Area
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        
        // NavigationBar
        let customNavigationBar = UINavigationBar(frame: .init(x: 0,
                                                         y: statusBarHeight,
                                                         width: view.frame.width,
                                                         height: statusBarHeight))
        customNavigationBar.isTranslucent = false
        customNavigationBar.backgroundColor = .systemBackground
        
        let customNavigationItem = UINavigationItem(title: "title")
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: nil)
        
        
        
    }

}

