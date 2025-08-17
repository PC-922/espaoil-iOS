//
//  AppEnvironment.swift
//  EspaOil
//
//  Created by Jose E on 17/8/25.
//

import Foundation

enum AppEnvironment: CaseIterable {
    case development
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://localhost:8080"
        case .production:
            return "https://espaoil-server.onrender.com"
        }
    }
    
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .production:
            return "Production"
        }
    }
}

final class AppConfiguration {
    static let shared = AppConfiguration()
    
    private init() {}
    
    // Configuración actual del entorno
    var currentEnvironment: AppEnvironment {
        get {
            #if DEBUG
            // En debug, permite cambiar entre entornos usando UserDefaults
            let environmentRawValue = UserDefaults.standard.string(forKey: "selectedEnvironment") ?? "development"
            return AppEnvironment.allCases.first { $0.rawValue == environmentRawValue } ?? .development
            #else
            // En release, siempre usa producción
            return .production
            #endif
        }
        set {
            #if DEBUG
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedEnvironment")
            #endif
        }
    }
    
    var baseURL: String {
        return currentEnvironment.baseURL
    }
}

// MARK: - Raw Value for UserDefaults
extension AppEnvironment: RawRepresentable {
    var rawValue: String {
        switch self {
        case .development:
            return "development"
        case .production:
            return "production"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "development":
            self = .development
        case "production":
            self = .production
        default:
            return nil
        }
    }
}