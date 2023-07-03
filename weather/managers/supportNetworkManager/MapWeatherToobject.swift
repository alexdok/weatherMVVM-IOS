//
//  MapWeatherToobject.swift
//  weather
//
//  Created by алексей ганзицкий on 01.02.2023.
//

import Foundation

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
