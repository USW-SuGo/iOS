//
//  PlaceViewController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/29.
//

import UIKit

protocol PlaceProtocol {
  func sendPlacePopVC(contactPlace: String)
  func designButton(contactPlace: String)
}

class PlaceViewController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  
  var delegate: PlaceProtocol?
  var place = ["지도보기", "정문", "인문대", "체대", "미래혁신관", "공대", "IT", "ACE교육관(구 종합강의동)",
               "학생회관", "건강과학대학", "중앙도서관", "글로벌경상대"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}

extension PlaceViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceCell
    cell.placeLabel.text = place[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return place.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if place[indexPath.row] != "지도보기" {
      let postingView = UIStoryboard(name: "PostingView", bundle: nil)
      let postingController = postingView.instantiateViewController(withIdentifier: "postingVC") as! PostingController
      var contactPlace = ""
      if place[indexPath.row] == "ACE교육관(구 종합강의동)" {
        contactPlace = "ACE교육관"
      } else {
        contactPlace = place[indexPath.row]
      }
      delegate?.sendPlacePopVC(contactPlace: contactPlace)
      delegate?.designButton(contactPlace: contactPlace)
      navigationController?.popViewController(animated: true)
    } else {
      let mapView = UIStoryboard(name: "MapView", bundle: nil)
      let mapController = mapView.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
      present(mapController, animated: true)
    }
  }
  
}

class PlaceCell: UITableViewCell {

  @IBOutlet weak var placeLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
}
