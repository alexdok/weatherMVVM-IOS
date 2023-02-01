//
//  String+extansion.swift
//  weather
//
//  Created by алексей ганзицкий on 08.11.2022.
//

import Foundation


extension String {
    
    func convertStringDellSpace() -> String {
        var cityConverted = ""
        for char in self {
            if char != " " {
                cityConverted.append(char)
            } else {
                cityConverted.append("%20")
            }
        }
        return cityConverted
    }
    
    func convertToString(format: FormateForLabelTime) -> String {
        switch format {
        case .date :
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            guard let convertDate = dateFormatter.date(from: self) else { return "loading" }
            dateFormatter.dateFormat = "dd.MMMM.yyyy"
            let newString = dateFormatter.string(from: convertDate)
            return newString
        case .time :
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            guard let convertDate = dateFormatter.date(from: self) else { return "loading" }
            dateFormatter.dateFormat = "HH:mm"
            let newString = dateFormatter.string(from: convertDate)
            return newString
        }
    }
    
    func convertDateStringToLastUpdateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let convertDate = dateFormatter.date(from: self) else { return "loading" }
        dateFormatter.dateFormat = "HH:mm"
        let newString = dateFormatter.string(from: convertDate)
        return newString
    }
    
    func checkCityNameForValidate() -> String {
        var convertString = self
        
        while convertString.last == " " {
            convertString.removeLast()
        }
        while convertString.first == " " {
            convertString.removeFirst()
        }
        for char in convertString {
            let lowChar = char.description.lowercased()
            let goodSymbols = "qazwsxedcrfvtgbyhnujmikolp -"
            if !goodSymbols.contains(lowChar) {
                return "404"
            }
        }
        return convertString
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
