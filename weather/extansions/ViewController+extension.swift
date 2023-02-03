//
//  ViewController+extansion.swift
//  weather
//
//  Created by алексей ганзицкий on 20.10.2022.
//

import Foundation
import UIKit

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == forecastDaysCollection) {
            data?.arrayOfCellsDays.removeFirst()
            return data?.arrayOfCellsDays.count ?? 0
        } else {
            return data?.arrayOfCellsTwentyFourHours.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == forecastDayHoursCollection) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellForecastHours", for: indexPath) as? CollectionViewCellForecastHours, let data = data else { return UICollectionViewCell() }
            cell.loadValueCell(objectCell: data.arrayOfCellsTwentyFourHours[indexPath.item]) //sometimes i have trouble out of range
                return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCellDays", for: indexPath) as? CollectionViewCellDays, let data = data else { return UICollectionViewCell()}
            cell.loadValueCell(objectCell: data.arrayOfCellsDays[indexPath.item])
            return cell
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.citiesList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCollectionCells", for: indexPath) as? CityCollectionCells else { return UITableViewCell() }

        cell.cityName.text = viewModel?.citiesList[indexPath.row].localized()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let city = viewModel?.citiesList[indexPath.row]
        findCityTF.text = city
        findCity()
        returnAnimate()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            viewModel?.citiesList.remove(at: indexPath.row)
            self.changeCityTable.deleteRows(at: [indexPath], with: .automatic)
            SaveSettingsManagerImpl.shared.saveCities(viewModel?.citiesList ?? [])
        }
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        findCity()
        returnAnimate()
        textField.text = ""
        return true
    }
}
