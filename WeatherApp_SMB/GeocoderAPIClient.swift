//
//  GeocoderAPIClient.swift
//  WeatherApp_SMB
//
//  Created by Samuel Boyce on 7/14/23.
//

import Foundation

struct GeocoderAPIClient {
  let apiKey = Cache.getSavedAPIKey() ?? "No Key Provided"
  
  func getCoordinatesFrom(city: String, completion: @escaping (Result<Coordinates, Error>) -> Void) {
    guard let escapedCityString = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
    guard let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(escapedCityString)&limit=1&appid=\(apiKey)") else {
      completion(.failure(GeocoderAPIError(desc: "Invalid URL")))
      return
    }
    let request = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
      if let data = data {
        let decoder = JSONDecoder()
        do {
          let coordinates = try decoder.decode([Coordinates].self, from: data)
          if let returnedCoordinates = coordinates.first {
            completion(.success(returnedCoordinates))
            print("Longitude: \(returnedCoordinates.lon)\nLatitude: \(returnedCoordinates.lat)")
          } else {
            completion(.failure(GeocoderAPIError(desc: "No Values Returned")))
          }
        } catch {
          completion(.failure(error))
          print("Error decoding weather data: \(error.localizedDescription)")
        }
      }
    }
    task.resume()
  }
}

struct Coordinates: Decodable {
  let lon: Float
  let lat: Float
}

struct GeocoderAPIError: Error {
  let localizedDescription: String
  
  init(desc: String) {
    self.localizedDescription = desc
  }
}
