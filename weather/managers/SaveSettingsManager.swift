

import Foundation

protocol SaveSettingsManager {
    func saveCities(_ cities: [String])
    func save(_ city: String)
    func loadCities() -> [String]
    func loadCity() -> String?
}

class SaveSettingsManagerImpl: SaveSettingsManager {
    static let shared = SaveSettingsManagerImpl()
    private init() {}
    
    func saveCities(_ cities: [String]) {
        UserDefaults.standard.set(cities, forKey: "arrayCitys")
    }
    
    func save(_ city: String) {
        UserDefaults.standard.set(city, forKey: "currentCity")
    }
    
    func loadCities() -> [String] {
        guard let loadValue = UserDefaults.standard.stringArray(forKey: "arrayCitys") else { return [] }
        return loadValue
    }
    
    func loadCity() -> String? {
        UserDefaults.standard.string(forKey: "currentCity")
    }
}
