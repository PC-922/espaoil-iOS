//
//  LocationManager.swift
//  Project01
//
//  Created by Jose E on 15/8/25.
//

import Foundation
import CoreLocation
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        errorMessage = nil
        isLoading = true
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            errorMessage = "Acceso a ubicación denegado. Ve a Configuración para habilitarlo."
            isLoading = false
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestLocation()
            } else {
                errorMessage = "Los servicios de ubicación están deshabilitados en el dispositivo."
                isLoading = false
            }
        @unknown default:
            isLoading = false
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
            self.errorMessage = nil
            self.isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Error al obtener ubicación: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.requestLocation()
                } else {
                    self.isLoading = false
                }
            case .denied, .restricted:
                self.errorMessage = "Acceso a ubicación denegado"
                self.isLoading = false
            default:
                self.isLoading = false
            }
        }
    }
}
