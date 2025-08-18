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
    @Published var selectedFuelType: FuelType {
        didSet {
            UserPreferences.shared.selectedFuelType = selectedFuelType
        }
    }
    @Published var searchRadiusKm: String {
        didSet {
            UserPreferences.shared.searchRadiusKm = searchRadiusKm
        }
    }
    
    private var allGasStations: [GasStation] = []
    private var userLocation: CLLocation?
    private let repository: GasStationRepositoryProtocol
    
    var searchRadiusValue: Double {
        guard let radius = Double(searchRadiusKm), radius.isFinite && radius > 0 else {
            return 10.0 // Valor por defecto seguro
        }
        return min(max(radius, 0.1), 100.0) // Limitar entre 0.1 y 100 km
    }
    
    init(repository: GasStationRepositoryProtocol = GasStationRepository()) {
        self.repository = repository
        self.selectedFuelType = UserPreferences.shared.selectedFuelType
        self.searchRadiusKm = UserPreferences.shared.searchRadiusKm
    }
    
    func searchNearbyGasStations(location: CLLocation) {
        isLoadingStations = true
        errorMessage = nil
        userLocation = location
        
        Task {
            do {
                let stations = try await repository.fetchGasStationsNearby(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    distance: searchRadiusValue,
                    fuelType: selectedFuelType
                )
                
                await MainActor.run {
                    self.allGasStations = stations
                    self.applySorting()
                    self.isLoadingStations = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error al cargar gasolineras: \(error.localizedDescription)"
                    self.isLoadingStations = false
                }
            }
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
            gasStations = allGasStations.sorted { station1, station2 in
                let price1 = station1.priceDouble
                let price2 = station2.priceDouble
                
                // Asegurar que ambos precios son válidos
                guard price1.isFinite && price2.isFinite else {
                    if !price1.isFinite && price2.isFinite { return false }
                    if price1.isFinite && !price2.isFinite { return true }
                    return false // Ambos inválidos, mantener orden
                }
                
                return price1 < price2
            }
        case .distance:
            guard let userLocation = userLocation else {
                gasStations = allGasStations
                return
            }
            gasStations = allGasStations.sorted { station1, station2 in
                guard let distance1 = station1.distance(from: userLocation),
                      let distance2 = station2.distance(from: userLocation),
                      distance1.isFinite && distance2.isFinite else {
                    // Si una distancia es inválida, ponerla al final
                    if station1.distance(from: userLocation) == nil { return false }
                    if station2.distance(from: userLocation) == nil { return true }
                    return false
                }
                return distance1 < distance2
            }
        }
    }
}
