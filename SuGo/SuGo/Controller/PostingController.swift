//
//  PostingController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/21.
//

import UIKit

class PostingController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var sugoButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    
    //MARK: Properties
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designButtons()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Button Actions
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sugoButtonClicked(_ sender: Any) {
    }
    
    @IBAction func placeButtonClicked(_ sender: Any) {
    }
    
    //MARK: Design Functions
    
    private func designButtons() {
        
        sugoButton.layer.cornerRadius = 12.0
        sugoButton.layer.borderColor = UIColor.white.cgColor
        
        placeButton.layer.cornerRadius = 12.0
        placeButton.layer.borderColor = UIColor.white.cgColor

    }
    
}
