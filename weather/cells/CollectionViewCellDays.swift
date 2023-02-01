//
//  CollectionViewCell.swift
//  weather
//
//  Created by алексей ганзицкий on 12.10.2022.
//

import UIKit

class CollectionViewCellDays: UICollectionViewCell {
//    var network = NetworkManagerImp
    var date: String = "загрузка"
    var temp: Double = 0
    var icon: String = "загрузка"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadVieCell() {
        loadImage(urlForImage: icon) { image in
            DispatchQueue.main.async {
                self.iconImage.image = image
            }
        }
        self.dateLabel.text = "\(convertDateToString())"
        self.tempLabel.text = "\(temp) °C"
        
    }
    
    func loadValueCell(objectCell: ForecastDayArray) {
        date = objectCell.date
        temp = objectCell.day.avgtempC
        icon = objectCell.day.condition.icon
        loadVieCell()
    }
    
    func convertDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let convertDate = dateFormatter.date(from: date) else { return " " }
        dateFormatter.dateFormat = "dd.MM.yy"
        let newString = dateFormatter.string(from: convertDate)
        return newString
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
