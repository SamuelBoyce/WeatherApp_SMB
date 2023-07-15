//
//  WeatherAPIClient.swift
//  WeatherApp_SMB
//
//  Created by Samuel Boyce on 7/11/23.
//

import UIKit

struct WeatherAPIClient {
  let apiKey = Cache.getSavedAPIKey() ?? "No Key Provided"
  
  func getWeather(from coordinates: Coordinates, completion: @escaping (Result<WeatherInfo, Error>) -> Void) {
    guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.lat)&lon=\(coordinates.lon)&appid=\(apiKey)") else {
      completion(.failure(WeatherAPIError()))
      return
    }
    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
      if let data = data {
        let decoder = JSONDecoder()
        do {
          let decodedWeather = try decoder.decode(WeatherInfo.self, from: data)
          completion(.success(decodedWeather))
          print("Condition: \(decodedWeather.weather[0].description)\nTemperature: \(decodedWeather.main.temp)")
        } catch {
          completion(.failure(error))
          print("Error decoding weather data: \(error.localizedDescription)")
        }
      }
    }
    task.resume()
  }
  
  func getIcon(from code: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
    guard let url = URL(string: "https://openweathermap.org/img/wn/\(code)@2x.png") else {
      completion(.failure(WeatherAPIError()))
      return
    }
    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
      if let data = data, let image = UIImage(data: data, scale: 2.0) {
        completion(.success(image))
        print(data)
      } else {
        completion(.failure(WeatherAPIError()))
      }
    }
    task.resume()
  }
}

struct WeatherAPIError: Error {
  let localizedDescription = "Weather API Error"
}

struct WeatherInfo: Decodable {
  let weather: [Weather]
  let main: Main
  let name: String
  
  struct Weather: Decodable {
    let description: String
    let icon: String
  }
  
  struct Main: Decodable {
    let temp: Float
  }
}
