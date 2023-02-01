import UIKit
import CoreLocation

final class MainViewController: UIViewController, CLLocationManagerDelegate {
    private let spinnerLoadingIndicator = ActivityIndicator()
    var data: ObjectWeatherData?
    var viewModel: ViewModel!
    
    @IBOutlet weak var forecastDaysCollection: UICollectionView!
    @IBOutlet weak var forecastDayHoursCollection: UICollectionView!
    @IBOutlet weak var myCityLocation: UIButton!
    @IBOutlet weak var timeLabelCurrent: UILabel!
    @IBOutlet weak var forecastForFiveDaysButtonConstraintForHideOrNot: NSLayoutConstraint!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var presureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var forecastForFiveDaysButton: UIButton!
    @IBOutlet weak var containerForCollectionViewHours: UIView!
    @IBOutlet weak var dailyForecastButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dailyForecastButton: UIButton!
    @IBOutlet weak var noInternetConnectionLabel: UILabel!
    @IBOutlet weak var timeLabelDate: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var changeCityTable: UITableView!
    @IBOutlet weak var leftConstraintOutlet: NSLayoutConstraint!
    @IBOutlet weak var containerForCollectionView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imageForTemp: UIImageView!
    @IBOutlet weak var findCityTF: UITextField!
    @IBOutlet weak var visualBlurEffect: UIVisualEffectView!
    @IBOutlet weak var viewForChangeCity: UIView!
    @IBOutlet weak var viewForCancel: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        spinnerLoadingIndicator.showLoading(onView: view)
        viewModel.viewIsReady()
        bindSubiewsToViewModel()

        configureCollectionViews()
        configureBackground()
        configureGestureRecognizer()
    }

    // MARK: - Configure methods
    private func configureCollectionViews() {
        self.forecastDaysCollection.dataSource = self
        self.forecastDaysCollection.delegate = self
        self.forecastDayHoursCollection.dataSource = self
        self.forecastDayHoursCollection.delegate = self
    }

    private func configureBackground() {
        background.image = UIImage(named: "background")
        background.addParalaxEffect()
    }

    private func configureGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapForReturn))
        viewForCancel.addGestureRecognizer(recognizer)
    }

    // MARK: - IBAction methods
    @IBAction func changeCityButtonPressed(_ sender: UIButton) {
        leftConstraintOutlet.constant += viewForChangeCity.bounds.width
        viewForChangeCity.isHidden = false
        viewForCancel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.visualBlurEffect.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func myCityLocationButtonPressed(_ sender: UIButton) {
        viewModel.viewIsReady()
        bindSubiewsToViewModel()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.spinnerLoadingIndicator.hideLoading()
        }
        self.returnAnimate()
    }
    
    @IBAction func dailyForecastHideOrNotButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            self.forecastDayHoursCollection.alpha = 0
            self.forecastDayHoursCollection.isHidden = false
            forecastForFiveDaysButtonConstraintForHideOrNot.constant = containerForCollectionViewHours.bounds.height - 15
            dailyForecastButtonBottomConstraint.constant = 15
            dailyForecastButton.frame.size.height = 15
            UIView.animate(withDuration: 0.3) {
                self.containerForCollectionViewHours.layoutIfNeeded()
                self.forecastDayHoursCollection.alpha = 1
            }
        } else {
            forecastForFiveDaysButtonConstraintForHideOrNot.constant = 80
            dailyForecastButtonBottomConstraint.constant = 40
            UIView.animate(withDuration: 0.3) {
                self.containerForCollectionViewHours.layoutIfNeeded()
                self.forecastDayHoursCollection.alpha = 0
            } completion: { _ in
                self.forecastDayHoursCollection.isHidden = true
            }
        }
    }
    
    @IBAction func forecastForFiveDaysHideOrNotButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if data?.arrayOfCellsDays.count ?? 0 < 5 && sender.isSelected {
            createAlertProblemsWithAPIForecast()
        }
        if sender.isSelected {
            UIView.animate(withDuration: 0.3) {
                self.windLabel.alpha = 0
                self.presureLabel.alpha = 0
                self.feelsLikeLabel.alpha = 0
                self.forecastDaysCollection.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.forecastDaysCollection.isHidden = false
                    self.forecastDaysCollection.alpha = 1
                }
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.forecastDaysCollection.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.windLabel.alpha = 1
                    self.presureLabel.alpha = 1
                    self.feelsLikeLabel.alpha = 1
                    self.forecastDaysCollection.isHidden = true
                }
            }
        }
    }
    
    @IBAction func findCityButtonPressed(_ sender: UIButton) {
        findCity()
        returnAnimate()
    }
    
    @IBAction func tapForReturn() {
        returnAnimate()
    }
    
    func findCity() {
        if findCityTF.text?.checkCityNameForValidate() == nil {
            return
        }
       let cityName = findCityTF.text?.checkCityNameForValidate()
        if cityName == "404"  {
            createAlertCityNotFound()
        } else {
            viewModel.updateCity(cityName: cityName?.convertStringDellSpace())
        }
        findCityTF.text = nil
    }
    
    func bindSubiewsToViewModel() {
        viewModel.weatherObjectData.bind { [weak self] data in
            guard let data = data, let self = self else {
                return
            }
            
            self.data = data
            DispatchQueue.main.async {
                self.cityLabel.text = data.city
                self.tempLabel.text = "\(data.temp) °C"
                self.timeLabelDate.text = data.localTime.convertToString(format: .date)
                self.timeLabelCurrent.text = data.localTime.convertToString(format: .time)
                self.feelsLikeLabel.text = "Feels like: \(data.tempFeelsLike) °C"
                self.windLabel.text = "Wind: \(data.windMph) mph"
                self.presureLabel.text = "Presure: \(data.presure)"
                self.spinnerLoadingIndicator.hideLoading()
                self.forecastDaysCollection.reloadData()
                self.forecastDayHoursCollection.reloadData()
            }
        }
        viewModel.currentImageTemp.bind { [weak self] image in
            guard let image = image else {
                return
            }
            DispatchQueue.main.async {
                self?.imageForTemp.image = image
            }
        }

    }
  // MARK: allerts
    func createAlertCityNotFound() {
        let alert = UIAlertController.init(title: "WARNING!", message: "bad symbols in search field", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: self.spinnerLoadingIndicator.hideLoading )
    }
    
    func createAlertProblemsWithAPIForecast() {
        let alert = UIAlertController.init(title: "sorry!", message: "now we can show you only 2 days!", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil )
    }
    
    // MARK: animate
    func returnAnimate() {
        leftConstraintOutlet.constant -= viewForChangeCity.bounds.width
        self.spinnerLoadingIndicator.showLoading(onView: self.view)
        viewForCancel.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.visualBlurEffect.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.changeCityTable.reloadData()
            }
        } completion: { _ in
            self.viewForChangeCity.isHidden = true
            self.spinnerLoadingIndicator.hideLoading()
        }
    }
}



