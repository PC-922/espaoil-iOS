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
            errorMessage = String(localized: "location.access.denied")
            isLoading = false
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationRequest()
        @unknown default:
            isLoading = false
        }
    }
    
    private func startLocationRequest() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager.requestLocation()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = String(localized: "location.services.disabled")
                    self.isLoading = false
                }
            }
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
            self.errorMessage = String(localized: "location.error \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            // Solo iniciar ubicación si hay una solicitud pendiente (isLoading = true)
            guard self.isLoading else { return }
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationRequest()
            case .denied, .restricted:
                self.errorMessage = String(localized: "location.access.denied")
                self.isLoading = false
            case .notDetermined:
                // Esperando respuesta del usuario, mantener isLoading = true
                break
            @unknown default:
                self.isLoading = false
            }
        }
    }
}
