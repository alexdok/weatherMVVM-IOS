//
//  CollectionViewCellForecastDay.swift
//  weather
//
//  Created by алексей ганзицкий on 24.10.2022.


import UIKit

class CollectionViewCellForecastHours: UICollectionViewCell {
//    var network = NetworkManagerImpl()
    var time: String = "загрузка"
    var temp: Double = 0
    var icon: String = "загрузка"
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        loadImage()
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    func loadViewCell() {
        loadImage(urlForImage: icon) { image in
            DispatchQueue.main.async {
                self.iconImage.image = image
            }
        }
        self.timeLabel.text = convertDateToString()
        self.tempLabel.text = "\(temp) °C"
    }
    
    func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let convertDate = dateFormatter.date(from: time) else { return " " }
        dateFormatter.dateFormat = "HH:mm"
        let newString = dateFormatter.string(from: convertDate)
        return newString
    }
    
    func loadValueCell(objectCell: Hours) {
        time = objectCell.time
        temp = objectCell.tempC
        icon = objectCell.condition.icon
        loadViewCell()
    }
    
    func loadImage(urlForImage: String, completion: @escaping (UIImage) -> ()) {
        let urlObj = "https:\(urlForImage)"
        guard let urlImage = URL(string: urlObj) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlImage) { (data, response, error) in
            if let data = data, error == nil {
                guard let image = UIImage(data: data) else { return }
                completion(image)
            }
        }
        task.resume()
    }
}
