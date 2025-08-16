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
        return Double(searchRadiusKm) ?? 10.0
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
}
