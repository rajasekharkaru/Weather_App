//
//  WeatherAPI.swift
//  MapKitTask
//
//  Created by apple on 13/04/23.
//

import Foundation

//MARK: - Namespacing for API
struct API {
    static let key = URLQueryItem(name: "APPID", value: .apiKey)
    
    //MARK: URL EndPoints
    static var baseURL = URLComponents(string: .url)
    
    //Basic Weather URL
    static func locationForecast(_ city: String) -> URL?  {
        API.baseURL?.queryItems?.append(URLQueryItem(name: .query, value: city))
        API.baseURL?.queryItems?.append(API.key)
        return API.baseURL?.url
    }
}


extension String {
    static let apiKey = "03163085893676bafd56855bf2351831"
    static let url = "https://api.openweathermap.org/data/2.5/weather?"
    static let query = "q"
}


//Utility extension to help with certain data types and calculations
extension CurrentWeatherData {
    var timeOfDataCalculation: Date {
        return Date(timeIntervalSince1970: self.dt!)
    }
}

extension CurrentWeatherData.Main {
    //Calculate Celcius and Fahrenheit Values
    func getFahrenheit(valueInKelvin: Double?) -> Double {
        if let kelvin = valueInKelvin {
            return ((kelvin - 273.15) * 1.8) + 32
        } else {
            return 0
        }
    }
    
    func getCelsius(valueInKelvin: Double?) -> Double {
        if let kelvin = valueInKelvin {
            return kelvin - 273.15
        } else {
            return 0
        }
    }
    
    var minTempFahrenheit: Double {
        return getFahrenheit(valueInKelvin: self.minTempKelvin)
    }
    var minTempCelcius: Double {
        return getCelsius(valueInKelvin: self.minTempKelvin)
    }
    var maxTempFahrenheit: Double {
        return getFahrenheit(valueInKelvin: self.maxTempKelvin)
    }
    var maxTempCelcius: Double {
        return getCelsius(valueInKelvin: self.maxTempKelvin)
    }
}

extension CurrentWeatherData.Sys {
    var sunriseTime: Date {
        return Date(timeIntervalSince1970: self.sunrise!)
    }
    
    var sunsetTime: Date {
        return Date(timeIntervalSince1970: self.sunset!)
    }
}


//Codable Struct to represent JSON payload
struct CurrentWeatherData: Decodable {
    
    let weather: [Weather]?
    let coord: Coordinates?
    let base: String? ///Internal paramenter for station information
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Double?
    let sys: Sys?
    let cityId: Int?
    let cityName: String? ///City name
    let statusCode: Int? /// cod - Internal parameter for HTTP Response
    
    struct Weather: Decodable {
        let id: Int?
        let main: String?
        let description: String?
        let icon: String?
    }
    
    struct Coordinates: Decodable {
        let lon: Double?
        let lat: Double?
    }
    
    struct Main: Decodable {
        let tempKelvin: Double? ///Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
        var tempFahrenheit: Double {
            return getFahrenheit(valueInKelvin: self.tempKelvin)
        }
        var tempCelcius: Double {
            return getCelsius(valueInKelvin: self.tempKelvin)
        }
        let pressure: Int?
        let humidity: Int?
        let minTempKelvin: Double? /// used for large cities
        let maxTempKelvin: Double?
        
        private enum CodingKeys: String, CodingKey {
            case tempKelvin = "temp"
            case pressure
            case humidity
            case minTempKelvin = "temp_min"
            case maxTempKelvin = "temp_max"
        }
    }
    
    struct Wind: Decodable {
        let speed: Double?
        let deg: Int?
    }
    
    struct Clouds: Decodable {
        let all: Int? /// Percentage Value
    }
    
    struct Sys: Decodable {
        let type: Int?
        let id: Int?
        let message: Double?
        let country: String?
        let sunrise: Double?
        let sunset: Double?
    }
    
    private enum CodingKeys: String, CodingKey {
        case weather
        case coord
        case base
        case main
        case visibility
        case wind
        case clouds
        case dt
        case sys
        case cityId = "id"
        case cityName = "name"
        case statusCode = "cod"
    }
    
}


//Variables
var currentWeather = [CurrentWeatherData]()
var errorMessage = ""

//Networking Code
let decoder = JSONDecoder()

fileprivate func updateResults(_ data: Data) {
    currentWeather.removeAll()
    do {
        decoder.dateDecodingStrategy = .iso8601
        let rawFeed = try decoder.decode(CurrentWeatherData.self, from: data)
        print("Status: \(rawFeed.statusCode ?? 0)")
        currentWeather = [rawFeed]
    } catch let decodeError as NSError {
        errorMessage += "Decoder error: \(decodeError.localizedDescription)"
        print(errorMessage)
        return
    }
}

func weatherData(from url: URL, completion: @escaping () -> ()) {
    URLSession.shared.dataTask(with: url) { (data, response, error ) in
        guard let data = data else { return }
        updateResults(data)
        completion()
    }.resume()
}
