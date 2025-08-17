//
//  GasStationServiceTests.swift
//  EspaOilTests
//
//  Created by Jose E on 17/8/25.
//

import Testing
import CoreLocation
@testable import EspaOil

@Suite("GasStationService Tests")
struct GasStationServiceTests {
    
    // MARK: - Initialization Tests
    
    @Test("Service initializes with correct default values")
    func serviceInitialization() async throws {
        // Given
        let mockRepository =  MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        
        // Then
        #expect(service.gasStations.count == 0)
        #expect(service.isLoadingStations == false)
        #expect(service.errorMessage == nil)
        #expect(service.sortOption == .price)
        #expect(service.selectedFuelType == UserPreferences.shared.selectedFuelType)
        #expect(service.searchRadiusKm == UserPreferences.shared.searchRadiusKm)
    }
    
    @Test("Search radius value converts correctly", arguments: [
        ("15", 15.0),
        ("25.5", 25.5),
        ("invalid", 10.0),
        ("", 10.0)
    ])
    func searchRadiusValue(input: String, expected: Double) async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        
        // When
        service.updateSearchRadius(input)
        
        // Then
        #expect(service.searchRadiusValue == expected)
    }
    
    // MARK: - Search Tests
    
    @Test("Search nearby gas stations succeeds")
    func searchNearbyGasStationsSuccess() async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        let mockStations = createMockGasStations()
        mockRepository.mockGasStations = mockStations
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038)
        
        // When
        service.searchNearbyGasStations(location: location)
        
        // Wait for async operation
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(service.gasStations.count == 3)
        #expect(service.isLoadingStations == false)
        #expect(service.errorMessage == nil)
        
        // Verify repository was called with correct parameters
        #expect(mockRepository.lastLatitude == 40.4168)
        #expect(mockRepository.lastLongitude == -3.7038)
        #expect(mockRepository.lastDistance == service.searchRadiusValue)
        #expect(mockRepository.lastFuelType == service.selectedFuelType)
    }
    
    @Test("Search nearby gas stations handles error")
    func searchNearbyGasStationsError() async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        mockRepository.shouldThrowError = true
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038)
        
        // When
        service.searchNearbyGasStations(location: location)
        
        // Wait for async operation
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        #expect(service.gasStations.count == 0)
        #expect(service.isLoadingStations == false)
        #expect(service.errorMessage != nil)
        #expect(service.errorMessage?.contains("Error al cargar gasolineras") == true)
    }
    
    @Test("Search sets loading state immediately")
    func searchSetsLoadingState() async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        mockRepository.delay = 1.0
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038)
        
        // When
        service.searchNearbyGasStations(location: location)
        
        // Then (immediately after calling)
        #expect(service.isLoadingStations == true)
        #expect(service.errorMessage == nil)
    }
    
    // MARK: - Sorting Tests
    
    @Test("Sort by price orders stations correctly")
    func sortByPrice() async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        let mockStations = createMockGasStations()
        mockRepository.mockGasStations = mockStations
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038)
        
        service.searchNearbyGasStations(location: location)
        try await Task.sleep(for: .milliseconds(100))
        
        // When
        service.updateSortOption(.price)
        
        // Then
        #expect(service.sortOption == .price)
        #expect(service.gasStations[0].price == "1.200") // Cheapest first
        #expect(service.gasStations[1].price == "1.300")
        #expect(service.gasStations[2].price == "1.450")
    }
    
    @Test("Sort by distance orders stations correctly")
    func sortByDistance() async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        let mockStations = createMockGasStationsWithCoordinates()
        mockRepository.mockGasStations = mockStations
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038) // Madrid center
        
        service.searchNearbyGasStations(location: location)
        try await Task.sleep(for: .milliseconds(100))
        
        // When
        service.updateSortOption(.distance)
        
        // Then
        #expect(service.sortOption == .distance)
        // The sorting should put the closest station first
        #expect(service.gasStations[0].name == "Estación Cercana") // Closest to Madrid center
    }
    
    // MARK: - Integration Tests
    
    @Test("Complete workflow: search, sort, and update preferences")
    func completeWorkflow() async throws {
        // Given
        let mockRepository = MockGasStationRepository()
        let service = GasStationService(repository: mockRepository)
        let mockStations = createMockGasStations()
        mockRepository.mockGasStations = mockStations
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038)
        
        // When - Search
        service.searchNearbyGasStations(location: location)
        try await Task.sleep(for: .milliseconds(100))
        
        // Then - Verify search results
        #expect(service.gasStations.count == 3)
        #expect(service.isLoadingStations == false)
        
        // When - Update preferences
        service.updateFuelType(.gasoilA)
        service.updateSearchRadius("20")
        service.updateSortOption(.distance)
        
        // Then - Verify all updates
        #expect(service.selectedFuelType == .gasoilA)
        #expect(service.searchRadiusKm == "20")
        #expect(service.sortOption == .distance)
        #expect(UserPreferences.shared.selectedFuelType == .gasoilA)
        #expect(UserPreferences.shared.searchRadiusKm == "20")
    }
}

// MARK: - Helper Functions

private func createMockGasStations() -> [GasStation] {
    return [
        GasStation(
            name: "Estación Cara",
            town: "Madrid",
            municipality: "Madrid",
            schedule: "24 horas",
            price: "1.450",
            latitude: "40.4168",
            longitude: "-3.7038"
        ),
        GasStation(
            name: "Estación Barata",
            town: "Madrid",
            municipality: "Madrid",
            schedule: "6:00-22:00",
            price: "1.200",
            latitude: "40.4200",
            longitude: "-3.7000"
        ),
        GasStation(
            name: "Estación Media",
            town: "Madrid",
            municipality: "Madrid",
            schedule: "7:00-23:00",
            price: "1.300",
            latitude: "40.4100",
            longitude: "-3.7100"
        )
    ]
}

private func createMockGasStationsWithCoordinates() -> [GasStation] {
    return [
        GasStation(
            name: "Estación Lejana",
            town: "Barcelona",
            municipality: "Barcelona",
            schedule: "24 horas",
            price: "1.350",
            latitude: "41.3851", // Barcelona (far from Madrid)
            longitude: "2.1734"
        ),
        GasStation(
            name: "Estación Cercana",
            town: "Madrid",
            municipality: "Madrid",
            schedule: "6:00-22:00",
            price: "1.400",
            latitude: "40.4169", // Very close to test location
            longitude: "-3.7039"
        ),
        GasStation(
            name: "Estación Media",
            town: "Toledo",
            municipality: "Toledo",
            schedule: "7:00-23:00",
            price: "1.250",
            latitude: "39.8628", // Toledo (medium distance)
            longitude: "-4.0273"
        )
    ]
}

// MARK: - Mock Repository

final class MockGasStationRepository: GasStationRepositoryProtocol {
    var mockGasStations: [GasStation] = []
    var shouldThrowError = false
    var delay: TimeInterval = 0
    
    // Track last called parameters
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastDistance: Double?
    var lastFuelType: FuelType?
    
    func fetchGasStationsNearby(
        latitude: Double,
        longitude: Double,
        distance: Double,
        fuelType: FuelType
    ) async throws -> [GasStation] {
        
        // Store parameters for verification
        lastLatitude = latitude
        lastLongitude = longitude
        lastDistance = distance
        lastFuelType = fuelType
        
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }
        
        if shouldThrowError {
            throw MockError.networkError
        }
        
        return mockGasStations
    }
}

enum MockError: Error, LocalizedError {
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Mock network error"
        }
    }
}
