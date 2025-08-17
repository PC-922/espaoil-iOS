//
//  UserPreferences.swift
//  EspaOil
//
//  Created by Jose E on 16/8/25.
//

import Foundation

final class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let selectedFuelType = "selectedFuelType"
        static let searchRadiusKm = "searchRadiusKm"
    }
    
    // MARK: - Fuel Type Preference
    var selectedFuelType: FuelType {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Keys.selectedFuelType),
                  let fuelType = FuelType(rawValue: rawValue) else {
                return Constants.defaultFuelType
            }
            return fuelType
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.selectedFuelType)
            objectWillChange.send()
        }
    }
    
    // MARK: - Search Radius Preference
    var searchRadiusKm: String {
        get {
            let value = UserDefaults.standard.string(forKey: Keys.searchRadiusKm)
            return value ?? Constants.defaultSearchRadius
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.searchRadiusKm)
            objectWillChange.send()
        }
    }
}

// MARK: - Constants
private extension UserPreferences {
    enum Constants {
        static let defaultFuelType: FuelType = .gasoline95E5
        static let defaultSearchRadius = "10"
    }
}