//
//  GasStationRepository.swift
//  EspaOil
//
//  Created by Jose E on 16/8/25.
//

import Foundation
import CoreLocation

// MARK: - Protocol
protocol GasStationRepositoryProtocol {
    func fetchGasStationsNearby(latitude: Double, longitude: Double, distance: Double, fuelType: FuelType) async throws -> [GasStation]
}

// MARK: - Repository Implementation
final class GasStationRepository: GasStationRepositoryProtocol {
    
    private let session = URLSession.shared
    private let baseURL = "http://localhost:8080"
    
    enum RepositoryError: Error {
        case invalidURL
        case noData
        case decodingError(Error)
        case networkError(Error)
    }
    
    // MARK: - Fetch gas stations nearby
    func fetchGasStationsNearby(latitude: Double, longitude: Double, distance: Double, fuelType: FuelType) async throws -> [GasStation] {
        
        // Construir la URL con los parámetros
        var components = URLComponents(string: "\(baseURL)/gas-stations/near")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "distance", value: String(Int(distance * 1000))), // Convertir km a metros
            URLQueryItem(name: "gasType", value: fuelType.rawValue)
        ]
        
        guard let url = components.url else {
            throw RepositoryError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let dtos = try JSONDecoder().decode([GasStationDTO].self, from: data)
            return GasStationMapper.toDomainList(from: dtos)
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw RepositoryError.decodingError(decodingError)
        } catch {
            print("Network error: \(error)")
            throw RepositoryError.networkError(error)
        }
    }
}

// MARK: - Mock Repository for Testing
final class MockGasStationRepository: GasStationRepositoryProtocol {
    
    func fetchGasStationsNearby(latitude: Double, longitude: Double, distance: Double, fuelType: FuelType) async throws -> [GasStation] {
        // Simular delay de red
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return GasStation.getMock(by: CLLocation(latitude: latitude, longitude: longitude))
    }
}
