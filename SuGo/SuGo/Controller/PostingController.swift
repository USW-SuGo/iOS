//
//  PostingController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/21.
//

import UIKit

import BSImagePicker
import Photos

class PostingController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sugoButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    
    //MARK: Properties
    
    var testList = [PHAsset]()
    var testImage = [UIImage]()
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designButtons()
        // Do any additional setup after loading the view.
    }
    
    private func imageSelectSetting() {
        
        let imagePicker = ImagePickerController()
        
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.theme.selectionFillColor = .white
        imagePicker.doneButtonTitle = "선택완료"
        imagePicker.cancelButton.tintColor = .white
        
        presentImagePicker(imagePicker, select: {
            asset in
        
            print("select")
                
        }, deselect: { asset in
            print("deselect")
            
        }, cancel: { asset in
            
            print("cancel")
            
        }, finish: { assets in
            
            print("finish")
            print(assets)
            
            self.testList.removeAll()
            self.testImage.removeAll()
            
            for i in 0..<assets.count {
                self.testList.append(assets[i])
            }
            
            self.convertAssetToImage()
            self.collectionView.reloadData()
            
        })
    }
    
    // PHAsset -> UIImage로 형변환
    private func convertAssetToImage() {
        
        if testList.count != 0 {
            
            for i in 0..<testList.count {
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                var thumbnail = UIImage()
                
                imageManager.requestImage(for: testList[i],
                                          targetSize: CGSize(width: 30, height: 30),
                                          contentMode: .aspectFit,
                                          options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                
                self.testImage.append(newImage! as UIImage)
            }
        }
        print(testImage)
    }
    
    
    //MARK: Button Actions
    
    @IBAction func selectPhotoButtonClicked(_ sender: Any) {
        imageSelectSetting()
    }
    
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

extension PostingController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostingCell",
                                                      for: indexPath) as! PostingCollectionViewCell

        cell.itemImage.image = testImage[indexPath.row]

        return cell
    }
}

class PostingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    
}
