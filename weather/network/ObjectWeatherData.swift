//
//  Manager.swift
//  weather
//
//  Created by алексей ганзицкий on 16.10.2022.
//

import Foundation
import CoreLocation

struct ObjectWeatherData {
    var arrayOfCellsDays:[ForecastDayArray] = []
    var arrayOfCellsTwentyFourHours:[Hours] = []
    var arrayOfCellsHoursNextDay:[Hours] = []
    var arrayCurrentHours:[Hours] = []
    var error: Int? = nil
    var temp: Double = 0
    var presure: Double = 0
    var tempFeelsLike: Double = 0
    var windMph: Double = 0
    var city: String = ""
    var urlForCurrentImage: String = ""
    var localTime: String = ""
    var lastUpdateTime: String = ""
    var firstStart = true
    
    var currentLatitude: CLLocationDegrees?
    var currentLongitude: CLLocationDegrees?
}
