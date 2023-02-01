import UIKit
import CoreLocation

class FakeNetworkManager: NetworkManager {
    func sendRequestForTemperature(in location: CLLocation?, nameLocation: String?, completion: @escaping (ObjectWeatherData?) -> Void) {
        isMethodCalled = true
    }
    
    var isMethodCalled = false
    func sendRequestForTemperature(in location: CLLocation, completion: @escaping (ObjectWeatherData?) -> Void) {
        isMethodCalled = true
    }
    func loadImage(urlForImage: String, completion: @escaping (UIImage) -> Void) {
        isMethodCalled = true
    }
}

enum FormateForLabelTime {
    case date
    case time
}

class ViewModel: NSObject {
    
    private let locationManager = CLLocationManager()
    private let workWithAPI: NetworkManager
    private let settingsManager: SaveSettingsManager = SaveSettingsManagerImpl.shared

    var weatherObjectData = Bindable<ObjectWeatherData?>(nil)
    var currentImageTemp = Bindable<UIImage?>(nil)

    var citiesList: [String] {
        get {
            return settingsManager.loadCities()
        }
        set {
            settingsManager.saveCities(newValue)
        }
    }
    
    init(networkManager: NetworkManager) {
        self.workWithAPI = networkManager
    }
    

    func viewIsReady() {
        setupLocationManager()
    }
    
    func updateCity(cityName: String?) {
        sendRequestForTemperature(in: nil, cityName: cityName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateCitiesList()
        }
    }
    
    func updateCitiesList() {
        guard let newCity = weatherObjectData.value?.city else { return }
        if !citiesList.contains(newCity) {
            citiesList.append(newCity)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func sendRequestForTemperature(in location: CLLocation?, cityName: String?) {
        isRequestOn = true
   
        workWithAPI.sendRequestForTemperature(in: location, nameLocation: cityName) { objectData in
            self.isRequestOn = false
            var modificationObjectData = objectData
            
            modificationObjectData?.arrayOfCellsTwentyFourHours = self.createArrayOfCellsHours(firstDayHours: objectData?.arrayOfCellsDays.first?.hour ?? [], nextDayHours: objectData?.arrayOfCellsDays[1].hour ?? [], lastUpdateTime: objectData?.lastUpdateTime ?? "")
            
            self.weatherObjectData.value = modificationObjectData
         
            self.workWithAPI.loadImage(urlForImage: objectData?.urlForCurrentImage ?? " ") { image in
                self.currentImageTemp.value = image
            }
        }
    }
    
    func createArrayOfCellsHours(firstDayHours:[Hours], nextDayHours: [Hours], lastUpdateTime: String ) -> [Hours] {
        var finalArrayfForNextTwentyFourHours: [Hours] = []
            for hour in firstDayHours {
                if hour.time > lastUpdateTime {
                    finalArrayfForNextTwentyFourHours.append(hour)
                }
            }
            for hour in nextDayHours {
                if hour.time.convertDateStringToLastUpdateTime() < lastUpdateTime.convertDateStringToLastUpdateTime() {
                    finalArrayfForNextTwentyFourHours.append(hour)
                }
            }
        return finalArrayfForNextTwentyFourHours
    }

    var isRequestOn = false
}

extension ViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, !isRequestOn else {
            return
        }
        sendRequestForTemperature(in: location,cityName: nil)// do something with location
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            manager.stopUpdatingLocation()
        }
    }
}
