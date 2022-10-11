//
//  PostingController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/21.
//

import UIKit

import Alamofire
import BSImagePicker
import SwiftyJSON
import Photos
import KeychainSwift

class PostingController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sugoButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    
    //MARK: Properties
    
    var phAssetImages = [PHAsset]()
    // priview images
    var priviewImages = [UIImage]()
    // real images
    var realImages = [UIImage]()
    
    let imgData = UIImage(named: "home")

    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
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
        imagePicker.cancelButton.tintColor = .black
        imagePicker.cancelButton.title = "취소" 
        
        presentImagePicker(imagePicker, select: {
            asset in
        }, deselect: { asset in
        }, cancel: { asset in
        }, finish: { assets in
            
            
            self.phAssetImages.removeAll()
            self.priviewImages.removeAll()
            self.realImages.removeAll()
            
            for i in 0..<assets.count {
                self.phAssetImages.append(assets[i])
            }
            
            self.convertAssetToPriviewImage()
            self.convertAssetToRealImage()
            
            self.collectionView.reloadData()
            })
    }
    
    // PHAsset -> UIImage로 형변환
    private func convertAssetToPriviewImage() {
        
        if phAssetImages.count != 0 {
            
            for i in 0..<phAssetImages.count {
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.deliveryMode = .opportunistic
                option.isSynchronous = true
                
                // UIImage Resize
                option.resizeMode = .exact
                var thumbnail = UIImage()

//                let widthRatio = testList[i].pixelWidth / 30
//                let heightRatio = testList[i].pixelHeight / 30
                
                imageManager.requestImage(for: phAssetImages[i],
                                          targetSize: CGSize(width: 40, height: 40),
                                          contentMode: .aspectFill,
                                          options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 0.9)
                let newImage = UIImage(data: data!)
                self.priviewImages.append(newImage! as UIImage)
                print("image size - \(thumbnail.pngData())")
                print("resize image size - \(thumbnail.jpegData(compressionQuality: 0.9))")
            }
            print(priviewImages)
        }
    }
    
    private func convertAssetToRealImage() {
        
        if phAssetImages.count != 0 {
            
            for i in 0..<phAssetImages.count {
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.deliveryMode = .opportunistic
                option.isSynchronous = true
                
                // UIImage Resize
                option.resizeMode = .exact
                var realImage = UIImage()

//                let widthRatio = testList[i].pixelWidth / 30
//                let heightRatio = testList[i].pixelHeight / 30
                
                // 원본 사이즈 그대로 유지
                imageManager.requestImage(for: phAssetImages[i],
                                          targetSize: CGSize(width: phAssetImages[i].pixelWidth,
                                                             height: phAssetImages[i].pixelHeight),
                                          contentMode: .aspectFill,
                                          options: option) { (result, info) in
                    realImage = result!
                }
                
                let data = realImage.jpegData(compressionQuality: 0.9)
                print("real images size - \(data)")
                
                let newImage = UIImage(data: data!)
                self.realImages.append(newImage! as UIImage)

            }
        }
    }
    
    //MARK: Button Actions
    
    @IBAction func selectPhotoButtonClicked(_ sender: Any) {
        imageSelectSetting()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sugoButtonClicked(_ sender: Any) {
        
        let url = API.BASE_URL + "/post"
        
        let header: HTTPHeaders = [
    
            "Authorization" : String(KeychainSwift().get("AccessToken") ?? "")
    
        ]
        
        let parameters: Parameters = [
            "title" : "한지석",
            "content" : "한지석",
            "price" : 30000,
            "contactPlace" : "미래혁신관",
            "category" : "서적"
        ]
  
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            for i in 0..<self.realImages.count {
                multipartFormData.append(self.realImages[i].pngData()!,
                                        withName: "multipartFileList",
                                        fileName: "\(self.titleTextField.text ?? "")+\(i)",
                                        mimeType: "image/png")
            }
        },
                  to: url,
                  usingThreshold: UInt64.init(),
                  method: .post,
                  headers: header).responseJSON { response in
            
            print("statusCode - \(response.response?.statusCode)")
            print("JSONdata - \(JSON(response.data))")
            print("response - \(response)")
            print("response.data - \(response.data)")
            
        }
//        AlamofireManager
//            .shared
//            .session
//            .upload(multipartFormData: { multipartFormData in
//                for (key, value) in parameters {
//                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
//                }
//                multipartFormData.append((self.imgData?.pngData())!,
//                                         withName: "multipartFileList",
//                                         fileName: "test.png",
//                                         mimeType: "image/png")
//
//            }, to: url)
//            .responseJSON { response in
//                print(response.value)
//                print(response.response?.statusCode)
//            }
        
//        for i in 0..<testImage.count {
//            let image = testImage[i]
//            UIImage.resize(image)
//        }
    }
    
    @IBAction func placeButtonClicked(_ sender: Any) {
    }
    
    @objc func imageDeleteButtonClicked(sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        priviewImages.remove(at: indexPath.row)
        realImages.remove(at: indexPath.row)
        self.collectionView.reloadData()
    
    }
    
    //MARK: Design Functions
    
    private func designButtons() {
        
        sugoButton.layer.cornerRadius = 20.0
        sugoButton.layer.borderColor = UIColor.white.cgColor
        
        placeButton.layer.cornerRadius = 6.0
        placeButton.layer.borderColor = colorLiteralGreen.cgColor
        placeButton.layer.borderWidth = 1.0

        imageButton.layer.cornerRadius = 5.0
        imageButton.layer.borderColor = UIColor.darkGray.cgColor
        imageButton.layer.borderWidth = 1.0
        
    }
    
}

extension PostingController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return priviewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostingCell",
                                                      for: indexPath) as! PostingCollectionViewCell

        cell.itemImage.image = priviewImages[indexPath.row]
        cell.itemImage.layer.cornerRadius = 5
        cell.itemImage.layer.borderWidth = 2
        cell.itemImage.layer.borderColor = UIColor.darkGray.cgColor

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(imageDeleteButtonClicked), for: .touchUpInside)

        return cell
        
    }
}

extension PostingController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: 50, height: 50)

        return size
        
    }
    
    
}

class PostingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
}
