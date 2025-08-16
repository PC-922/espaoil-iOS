//
//  GasStationService.swift
//  Project01
//
//  Created by Jose E on 15/8/25.
//

import Foundation
import CoreLocation

final class GasStationService: ObservableObject {
    @Published var gasStations: [GasStation] = []
    @Published var isLoadingStations: Bool = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption = .price
    @Published var selectedFuelType: FuelType = .gasoline95
    @Published var searchRadiusKm: String = "10" // Umbral en kilómetros como String para el TextField
    
    private var allGasStations: [GasStation] = []
    private var userLocation: CLLocation?
    
    // Computed property para obtener el radio como Double
    var searchRadiusValue: Double {
        return Double(searchRadiusKm) ?? 10.0
    }
    
    func searchNearbyGasStations(location: CLLocation) {
        isLoadingStations = true
        errorMessage = nil
        userLocation = location
        
        // Simulamos datos de ejemplo para la demo
        // En una app real, aquí harías una llamada a una API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.allGasStations = self.generateSampleGasStations(near: location)
            self.applySorting()
            self.isLoadingStations = false
        }
    }
    
    func updateSortOption(_ option: SortOption) {
        sortOption = option
        applySorting()
    }
    
    func updateFuelType(_ fuelType: FuelType) {
        selectedFuelType = fuelType
    }
    
    func updateSearchRadius(_ radius: String) {
        searchRadiusKm = radius
    }
    
    private func applySorting() {
        switch sortOption {
        case .price:
            gasStations = allGasStations.sorted { $0.priceDouble < $1.priceDouble }
        case .distance:
            guard let userLocation = userLocation else {
                gasStations = allGasStations
                return
            }
            gasStations = allGasStations.sorted { station1, station2 in
                guard let distance1 = station1.distance(from: userLocation),
                      let distance2 = station2.distance(from: userLocation) else { return false }
                return distance1 < distance2
            }
        }
    }
    
    private func generateSampleGasStations(near location: CLLocation) -> [GasStation] {
        GasStation.getMock(by: location)
    }
}
