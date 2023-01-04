//
//  PostingController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/21.
//

import UIKit

import Alamofire
import BSImagePicker
import KeychainSwift
import MaterialComponents
import Photos
import SwiftyJSON
import IQKeyboardManagerSwift

// iCloud에 올려져있는 사진이 추가되지 않는 버그 존재

class PostingController: UIViewController {
  
  //MARK: IBOutlets
  
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var priceTextField: UITextField!
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var placeButton: UIButton!
  @IBOutlet weak var imageButton: UIButton!
  @IBOutlet weak var categoryButton: UIButton!

  @IBOutlet weak var photoCount: UILabel!
  //MARK: Properties
  
  var phAssetImages = [PHAsset]()
  var priviewImages = [UIImage]()
  var uploadImages = [UIImage]()
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let textViewPlaceHolder = "수고할 상품에 대한 글을 작성해주세요! (거짓 정보 및 가품 등 문제가 될만한 글은 자동으로 삭제됩니다.)"
  let categorySelect = CategorySelect.shared
  let modifyData = ModifyProduct.shared
  var contactPlace = ""
  
  //MARK: Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textDelegates()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(postBottomDismissObserver),
                                           name: NSNotification.Name("postBottomDismiss"),
                                           object: nil)
    navigationController?.navigationBar.backgroundColor = .white
    designButtons()
    customRightBarButton()
    customLeftBarButton()
    customBackButton()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    modifyPostingDataUpdate()
    print(contactPlace)
  }

  
  @objc func postBottomDismissObserver(_ notification: Notification){
    DispatchQueue.main.async {
      self.customCategoryButton()
    }
  }
  
  private func imageSelectSetting() {
    let imagePicker = ImagePickerController()
    imagePicker.modalPresentationStyle = .fullScreen
    imagePicker.settings.selection.max = 5 // 최대 갯수
    imagePicker.settings.theme.selectionStyle = .numbered // 숫자로 유저에게 보여주기
    imagePicker.settings.fetch.assets.supportedMediaTypes = [.image] // 이미지만 허용
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
      self.uploadImages.removeAll()
      
      for i in 0..<assets.count {
          self.phAssetImages.append(assets[i])
      }
      
      guard self.phAssetImages.count > 0 else { return }
      self.convertAssetToPriviewImage()
      self.convertAssetToRealImage()
      })
  }
  
  // PHAsset -> UIImage로 형변환
  private func convertAssetToPriviewImage() {
    for i in 0..<phAssetImages.count {
      phImageManagerCustom(phAssetImages: phAssetImages,
                           index: i,
                           deliveryMode: .opportunistic,
                           isSynchronous: true,
                           resizeMode: .exact,
                           imageArray: &priviewImages)
    }
    collectionView.reloadData()
    photoCount.text = "\(priviewImages.count)/5"
  }
  
  private func convertAssetToRealImage() {
    for i in 0..<phAssetImages.count {
      phImageManagerCustom(phAssetImages: phAssetImages,
                           index: i,
                           deliveryMode: .opportunistic,
                           isSynchronous: true,
                           resizeMode: .exact,
                           imageArray: &uploadImages)
    }
  }
  
  private func phImageManagerCustom(phAssetImages: [PHAsset],
                                    index: Int,
                                    deliveryMode: PHImageRequestOptionsDeliveryMode,
                                    isSynchronous: Bool,
                                    resizeMode: PHImageRequestOptionsResizeMode,
                                    imageArray: inout [UIImage]) {
    
    PHImageRequestOptions().deliveryMode = deliveryMode
    PHImageRequestOptions().isSynchronous = isSynchronous
    // 이미지 요청을 동기적으로 처리할 지 여부
    // 동기처리를 true로 해놓을 경우 opportunistic으로 deliveryMode를 설정해도 의미 없음.
    
    var image: UIImage?
    
    // UIImage Resize
    PHImageRequestOptions().resizeMode = resizeMode
    // iCloud에 저장 되어있는 사진 업로드 시 문제 해결 해야함.
    PHImageManager.default().requestImage(for: phAssetImages[index],
                                          targetSize: CGSize(width: phAssetImages[index].pixelWidth,
                                                             height: phAssetImages[index].pixelHeight),
                                          contentMode: .aspectFill,
                                          options: PHImageRequestOptions()) { (result, info) in
      guard result != nil else { return }
      image = result
    }
    guard let data = image?.jpegData(compressionQuality: 0.9) else { return }
    guard let appendImage = UIImage(data: data) else { return }
    imageArray.append(appendImage)
  }
  
  private func postContent(title: String,
                           content: String,
                           priceText: String,
                           contactPlace: String,
                           category: String,
                           modify: Bool) {
      
    let url = API.BASE_URL + "/post"
    var method: HTTPMethod = .post
    let header: HTTPHeaders = [
        "Authorization" : String(KeychainSwift().get("AccessToken") ?? "")
    ]
    
    let price: Int = Int(priceText) ?? 0
    
    var parameters: Parameters = [
      "title" : title,
      "content" : content,
      "price" : price,
      "contactPlace" : contactPlace,
      "category" : category
    ]
    
    if modify {
      guard let productPostId = modifyData.productIndex else { return }
      parameters.updateValue(productPostId, forKey: "productPostId")
      method = .put
    }
      
    // MultipartFormData - 이미지 파일 & 글 전송 logic
    // png = 원본 , jpeg = 압축하는 형태 --> jpeg로 변환 후 전송
    AF.upload(multipartFormData: { multipartFormData in
        
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
        }
        
        for i in 0..<self.uploadImages.count {
            multipartFormData.append(self.uploadImages[i].jpegData(compressionQuality: 1)!,
                                    withName: "multipartFileList",
                                    fileName: "\(self.titleTextField.text ?? "")+\(i)",
                                    mimeType: "image/jpeg")
        }
    },
              to: url,
              usingThreshold: UInt64.init(),
              method: method,
              headers: header).responseJSON { response in
      print("modify - \(modify)")
      print("method - \(method)")
      print(JSON(response.data ?? ""))
      self.modifyData.productIndex = nil
    }
      self.dismiss(animated: true)
  }
  
  private func textDelegates() {
    titleTextField.delegate = self
    priceTextField.delegate = self
    contentTextView.delegate = self
  }
    

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  //MARK: Button Actions
  
  @objc func finishButtonClicked() { // 조건 추가 필요.
    let title = titleTextField.text?.count ?? 0
    let content = contentTextView.text.count
    let price = priceTextField.text?.count ?? 0
    let category = categorySelect.postCategory
    // text or place 모두 선택 되었을 시 함수 실행
    // 이후에 거래장소도 추가
  
    if title > 0 && content > 0  && contentTextView.text != textViewPlaceHolder && price > 0 && category != "" {
      
      var modify = false
      if modifyData.productIndex != nil {
        modify = true
      }
      
      postContent(title: titleTextField.text ?? "",
                  content: contentTextView.text ?? "",
                  priceText: priceTextField.text ?? "",
                  contactPlace: contactPlace,
                  category: categorySelect.postCategory,
                  modify: modify)

    } else {
        customAlert(title: "모두 입력해주세요 !",
                    message: "입력되지 않은 정보가 있어요 !")
    }
  }
    
  
  @objc func closeButtonClicked() {
    modifyData.title = nil
    modifyData.category = nil
    modifyData.productIndex = nil
    modifyData.price = nil
    dismiss(animated: true)
  }
  
  @IBAction func priceTextFieldChanged(_ sender: Any) {
    checkMaxLength(textField: priceTextField, maxLength: 9)
  }
  
  
  @IBAction func categoryButtonClicked(_ sender: Any) {
    let bottomSheetView = UIStoryboard(name: "PostingBottomSheetView", bundle: nil)
    let nextVC = bottomSheetView.instantiateViewController(withIdentifier: "postingBottomSheetVC") as! PostingBottomSheetController
    let bottomSheet = MDCBottomSheetController(contentViewController: nextVC)
    bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 280
    bottomSheet.dismissOnDraggingDownSheet = true
    present(bottomSheet, animated: true)
  }
  
  @IBAction func selectPhotoButtonClicked(_ sender: Any) {
      imageSelectSetting()
  }
  
  @IBAction func placeButtonClicked(_ sender: Any) {
    let placeView = UIStoryboard(name: "PlaceView", bundle: nil)
    let placeController = placeView.instantiateViewController(withIdentifier: "placeVC") as! PlaceViewController
    placeController.delegate = self
    navigationController?.pushViewController(placeController, animated: true)
  }
  
  @objc func imageDeleteButtonClicked(sender: UIButton) {
    let indexPath = IndexPath(row: sender.tag, section: 0)
    priviewImages.remove(at: indexPath.row)
    uploadImages.remove(at: indexPath.row)
    photoCount.text = "\(priviewImages.count)/5"
    collectionView.reloadData()
  }
  
  //MARK: Design Functions
  
  private func customBackButton() {
      let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
      backButtonItem.tintColor = .darkGray
      self.navigationItem.backBarButtonItem = backButtonItem
  }
  
  private func modifyPostingDataUpdate() {
    if modifyData.productIndex != nil {
      titleTextField.text = modifyData.title
      if let category = modifyData.category {
        categorySelect.postCategory = category
        customCategoryButton()
      }
      priceTextField.text = modifyData.price
    }
  }
  
  private func customLeftBarButton() {
    let finishButton = self.navigationItem.makeWordButton(self,
                                                          action: #selector(finishButtonClicked),
                                                          title: "완료")
    self.navigationItem.leftBarButtonItem = finishButton
  }
  
  private func customRightBarButton() {
    let closeButton = self.navigationItem.makeSFSymbolButton(self,
                                                             action: #selector(closeButtonClicked),
                                                             symbolName: "xmark")
    self.navigationItem.rightBarButtonItem = closeButton
  }
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func customCategoryButton() {
    categoryButton.setTitle(categorySelect.postCategory, for: .normal)
    categoryButton.setTitleColor(.black, for: .normal)
  }
  
  private func designButtons() {
    contentTextView.layer.cornerRadius = 6.0
    contentTextView.text = textViewPlaceHolder
    contentTextView.textColor = .lightGray
//        contentTextView.layer.borderColor = UIColor.black.cgColor
//        contentTextView.layer.borderWidth = 1.0
    placeButton.layer.cornerRadius = 6.0
    placeButton.layer.borderColor = colorLiteralGreen.cgColor
    placeButton.layer.borderWidth = 1.0

    imageButton.layer.cornerRadius = 5.0
    imageButton.layer.borderColor = UIColor.darkGray.cgColor
    imageButton.layer.borderWidth = 1.0
  }
  
}

extension PostingController: PlaceProtocol {
  
  func sendPlacePopVC(contactPlace: String) {
    self.contactPlace = contactPlace
  }
  
  func designButton(contactPlace: String) {
    //Pretendard-SemiBold 16.0
    placeButton.setTitle(contactPlace, for: .normal)
    placeButton.setTitleColor(.white, for: .normal)
    placeButton.backgroundColor = colorLiteralGreen
  }
}

extension PostingController: UITextFieldDelegate {
  
  func checkMaxLength(textField: UITextField!, maxLength: Int) {
      if textField.text?.count ?? 0 > maxLength {
          textField.deleteBackward()
      }
  }
  
}

extension PostingController: UITextViewDelegate {
  
//  func textViewDidChange(_ textView: UITextView) {
//    let size = CGSize(width: view.frame.width, height: .infinity)
//    let estimatedSize = textView.sizeThatFits(size)
//    textView.constraints.forEach { constraint in
//      if constraint.firstAttribute == .height {
//        constraint.constant = estimatedSize.height
//      }
//    }
//  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
      if contentTextView.text == textViewPlaceHolder {
          contentTextView.text = nil
          contentTextView.textColor = .black
      }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
      if contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          contentTextView.text = textViewPlaceHolder
          contentTextView.textColor = .lightGray
      }
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
    cell.itemImage.contentMode = .scaleAspectFill
    cell.itemImage.layer.cornerRadius = 5
    cell.itemImage.layer.borderWidth = 2
    cell.itemImage.layer.borderColor = UIColor.white.cgColor
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
