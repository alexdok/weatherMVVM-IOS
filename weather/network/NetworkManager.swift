import Foundation
import UIKit
import CoreLocation

protocol NetworkManager {
    func sendRequestForTemperature(in location: CLLocation?, nameLocation: String?, completion: @escaping (ObjectWeatherData?) -> Void)
    func loadImage(urlForImage: String, completion: @escaping (UIImage) -> Void)
}

class NetworkManagerImpl: NetworkManager {
    private let mapper: MapWeatherToObject

    init(mapper: MapWeatherToObject) {
        self.mapper = mapper
    }

    func sendRequestForTemperature(in location: CLLocation?, nameLocation: String?, completion: @escaping (ObjectWeatherData?) -> Void) {
        var nameCityOrCoordinate = " "
      
        if let latitude = location?.coordinate.latitude,
          let longitude = location?.coordinate.longitude {
        nameCityOrCoordinate = "\(latitude),\(longitude)"
        } else {
            guard let nameLocation = nameLocation else { return }
            nameCityOrCoordinate = nameLocation
        }
       
        let urlString = "https://api.weatherapi.com/v1/forecast.json?q=\(nameCityOrCoordinate)&days=6&aqi=no&alerts=no"

        guard let url = URL(string: urlString) else {
            fatalError("Wrong URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(Constants.weatherApiKey, forHTTPHeaderField: "key")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
}

private extension NetworkManagerImpl {
    enum Constants {
        static let weatherApiKey = "57412865e5694920b65102314220712"
    }
}

protocol MapWeatherToObject {
    func map(_ weather: Weather) -> ObjectWeatherData?
}

struct MapWeatherToObjectImpl: MapWeatherToObject {
    func map(_ weather: Weather) -> ObjectWeatherData? {
        guard let forecast = weather.forecast else {
            return nil
        }
        guard let forecastHours = forecast.forecastday.first?.hour else {
            return nil
        }
        var resultObject  = ObjectWeatherData()
        resultObject.arrayOfCellsDays = forecast.forecastday
        resultObject.arrayCurrentHours = forecastHours
        resultObject.localTime = weather.location?.localtime ?? " "
        resultObject.lastUpdateTime = weather.current?.lastUpdated ?? " "
        resultObject.temp = weather.current?.tempC ?? 0
        resultObject.presure = weather.current?.pressureIn ?? 0
        resultObject.tempFeelsLike = weather.current?.feelslikeC ?? 0
        resultObject.windMph = weather.current?.windMph ?? 0
        resultObject.city = weather.location?.name ?? " "
        resultObject.urlForCurrentImage = weather.current?.condition.icon ?? " "

        return resultObject
    }
}

class FakeMapper: MapWeatherToObject {
    var callCount = 0

    func map(_ weather: Weather) -> ObjectWeatherData? {
        callCount += 1
        return .init()
    }
}

protocol RequestBuilder {
    func createRequestFrom(url: String, params: [String: String]) -> URLRequest?
}

class RequestBuilderImpl {
    func createRequestFrom(url: String, params: [String: String]) -> URLRequest? {
       let url = URL(string: "")
        let request = URLRequest(url: url!)
        return request
    }
}
