//
//  WeatherService.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-11-04.
//

import Foundation

struct WeatherResponse: Decodable {
    let main: Main
    
    struct Main: Decodable {
        let temp: Double      // °C (we’ll request metric units)
        let humidity: Double  // %
    }
}

enum WeatherError: Error, LocalizedError {
    case missingAPIKey
    case badURL
    case invalidResponse(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Missing OpenWeather API key."
        case .badURL: return "Bad OpenWeather URL."
        case .invalidResponse(let code): return "OpenWeather returned status \(code)."
        case .decoding(let err): return "Failed to decode weather JSON: \(err.localizedDescription)"
        }
    }
}

final class WeatherService {
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard !Secrets.openWeather.isEmpty else { throw WeatherError.missingAPIKey }

        // Metric units → Celsius
        let urlString =
          "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(Secrets.openWeather)&units=metric"

        guard let url = URL(string: urlString) else { throw WeatherError.badURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        #if DEBUG
        print("🌦️ [WeatherService] Status:", status)
        #endif

        guard status == 200 else { throw WeatherError.invalidResponse(status) }

        do {
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decoding(error)
        }
    }
}

