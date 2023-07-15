//
//  Cache.swift
//  WeatherApp_SMB
//
//  Created by Samuel Boyce on 7/14/23.
//

import Foundation

class Cache {
  static let lastCitySearchedKey = "lastCitySearched"
  static let apiKeyKey = "apiKeyKey"
  
  class func saveLastCitySearched(as city: String) {
    UserDefaults.standard.setValue(city, forKey: Cache.lastCitySearchedKey)
  }
  
  class func getLastCitySearched() -> String? {
    return UserDefaults.standard.string(forKey: Cache.lastCitySearchedKey)
  }
  
  class func saveAPIKey(as key: String) {
    UserDefaults.standard.setValue(key, forKey: Cache.apiKeyKey)
  }
  
  class func getSavedAPIKey() -> String? {
    return UserDefaults.standard.string(forKey: Cache.apiKeyKey)
  }
}
