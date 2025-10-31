//
//  File.swift
//  Leafy
//
//  Created by Dinachi Onuchukwu on 2025-10-31.
//

import Foundation

enum Secrets {
    static let plantNet: String = value(for: "PLANTNET_API_KEY")
    static let openWeather: String = value(for: "OPENWEATHER_API_KEY")
    static let azureFunctionURL: String = value(for: "AZURE_FUNCTION_URL")
    
    private static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let val = dict[key] as? String else { return "" }
        return val
    }
}
