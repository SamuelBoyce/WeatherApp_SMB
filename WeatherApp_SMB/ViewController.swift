//
//  ViewController.swift
//  WeatherApp_SMB
//
//  Created by Samuel Boyce on 7/11/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

  @IBOutlet var cityTextField: UITextField!
  @IBOutlet var searchButton: UIButton!
  @IBOutlet var cityNameLabel: UILabel!
  @IBOutlet var conditionLabel: UILabel!
  @IBOutlet var tempLabel: UILabel!
  @IBOutlet var weatherImageView: UIImageView!
    
  let apiClient = WeatherAPIClient()
  let geocoderClient = GeocoderAPIClient()
  //Given more time would abstract location services out of the view controller
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Ask for location access, if present load from current location, if not then look for a cached city search
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
      locationManager.startUpdatingLocation()
    } else if let lastCity = Cache.getLastCitySearched() {
      searchCityAndUpdateUI(city: lastCity)
    }
  }

  @IBAction func searchButtonTapped(_ sender: Any) {
    if let enteredCity = cityTextField.text {
      searchCityAndUpdateUI(city: enteredCity)
    }
  }
  
  func searchCityAndUpdateUI(city: String) {
    //Launch an API call and update the UI
    geocoderClient.getCoordinatesFrom(city: city) { [weak self] result in
      switch result {
        case .success(let coordinates):
          guard let strongSelf = self else { return }
          strongSelf.apiClient.getWeather(from: coordinates, completion: { result in
            switch result {
              case .success(let weatherInfo):
                strongSelf.updateUI(with: weatherInfo)
                Cache.saveLastCitySearched(as: weatherInfo.name)
              case .failure(let error):
                print(error)
            }
          })
        case .failure(let error):
          print(error)
      }
    }
  }
  
  //Update the UI of the weather display
  func updateUI(with weatherInfo: WeatherInfo) {
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.cityNameLabel.text = weatherInfo.name
      strongSelf.conditionLabel.text = weatherInfo.weather.first?.description
      let convertedTemp = (weatherInfo.main.temp - 273.15) * (9/5) + 32
      let formattedTemp = String(format: "%.0f", convertedTemp)
      strongSelf.tempLabel.text = "\(formattedTemp)° F"
    }
    if let icon = weatherInfo.weather.first?.icon {
      apiClient.getIcon(from: icon) { [weak self] result in
        guard let strongSelf = self else { return }
        switch result {
          case .success(let image):
            DispatchQueue.main.async {
              strongSelf.weatherImageView.image = image
            }
          case .failure(let error):
            print(error)
        }
      }
    }
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    let coordinates: Coordinates = Coordinates(lon: Float(locValue.longitude), lat: Float(locValue.latitude))
    apiClient.getWeather(from: coordinates) { [weak self] result in
      guard let strongSelf = self else { return }
      switch result {
        case .success(let weatherInfo):
          strongSelf.updateUI(with: weatherInfo)
        case .failure(let error):
          print(error)
      }
    }
  }
}
