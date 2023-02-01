import Foundation
import UIKit
import CoreLocation

protocol NetworkManager {
    func sendRequestForTemperature(in location: CLLocation?, nameLocation: String?, completion: @escaping (ObjectWeatherData?) -> Void)
    func loadImage(urlForImage: String, completion: @escaping (UIImage) -> Void)
}

class NetworkManagerImpl: NetworkManager {
    private let mapper: MapWeatherToObject
    private let requestBilder: RequestBuilder
    
    init(mapper: MapWeatherToObject, requestBilder: RequestBuilder) {
        self.mapper = mapper
        self.requestBilder = requestBilder
    }
    
    func sendRequestForTemperature(in location: CLLocation?, nameLocation: String?, completion: @escaping (ObjectWeatherData?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let nameCityOrCoordinate = nameLocationOrCoordinate(location: location, nameLocation: nameLocation)

        let URLParams = [
            "q": nameCityOrCoordinate,
            "days": "6",
            "key": Constants.weatherApiKey,
        ]
        
        guard let request = requestBilder.createRequestFrom(url: Constants.url, params: URLParams) else { return }

        /* Start a new Task */
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data {
                do {
                    let weather = try JSONDecoder().decode(Weather.self, from: data)
                    if let objectWeatherData = self.mapper.map(weather) {
                        completion(objectWeatherData)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func loadImage(urlForImage: String, completion: @escaping (UIImage) -> Void) {
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
    
    func nameLocationOrCoordinate(location: CLLocation?, nameLocation: String?) -> String {
        var nameCityOrCoordinate = " "
        if let latitude = location?.coordinate.latitude,
          let longitude = location?.coordinate.longitude {
        nameCityOrCoordinate = "\(latitude),\(longitude)"
        } else {
            if let nameLocation = nameLocation {
                nameCityOrCoordinate = nameLocation
            }
        }
        return nameCityOrCoordinate
    }
}

private extension NetworkManagerImpl {
    enum Constants {
        static let url = "https://api.weatherapi.com/v1/forecast.json"
        static let weatherApiKey = "57412865e5694920b65102314220712"
        
    }
}




