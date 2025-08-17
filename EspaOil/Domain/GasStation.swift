//
//  GasStation.swift
//  Project01
//
//  Created by Jose E on 15/8/25.
//

import Foundation
import CoreLocation

struct GasStation: Identifiable {
    let id = UUID()
    let name: String
    let town: String
    let municipality: String
    let schedule: String
    let price: String
    let latitude: String
    let longitude: String
    
    var priceDouble: Double {
        guard let price = Double(price.replacingOccurrences(of: ",", with: ".")) else {
            return 0.0
        }
        return price.isFinite ? price : 0.0
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = Double(latitude.replacingOccurrences(of: ",", with: ".")),
              let lon = Double(longitude.replacingOccurrences(of: ",", with: ".")),
              lat.isFinite && lon.isFinite,
              abs(lat) <= 90.0 && abs(lon) <= 180.0 else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var displayName: String {
        name
    }
    
    var fullAddress: String {
        if town.isEmpty {
            return municipality
        } else if town == municipality {
            return municipality
        } else {
            return "\(town), \(municipality)"
        }
    }
    
    // Calcular distancia desde una ubicación dada
    func distance(from location: CLLocation) -> Double? {
        guard let stationCoordinate = coordinate else { return nil }
        let stationLocation = CLLocation(latitude: stationCoordinate.latitude, longitude: stationCoordinate.longitude)
        let distance = location.distance(from: stationLocation)
        return distance.isFinite ? distance : nil
    }
    
    // Formato de distancia legible
    func formattedDistance(from location: CLLocation) -> String {
        guard let distance = distance(from: location), distance.isFinite else {
            return String(localized: "distance.unknown")
        }
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}

extension GasStation {
    static func getMock(by location: CLLocation) -> [GasStation] {
        [
            GasStation(
                name: "Estación Repsol Centro",
                town: "Madrid",
                municipality: "Madrid",
                schedule: "24 horas",
                price: "1.459",
                latitude: String(location.coordinate.latitude + 0.01),
                longitude: String(location.coordinate.longitude + 0.01)
            ),
            GasStation(
                name: "Cepsa Express",
                town: "Madrid",
                municipality: "Madrid",
                schedule: "06:00 - 22:00",
                price: "1.425",
                latitude: String(location.coordinate.latitude - 0.02),
                longitude: String(location.coordinate.longitude + 0.015)
            ),
            GasStation(
                name: "BP Station",
                town: "Alcorcón",
                municipality: "Madrid",
                schedule: "24 horas",
                price: "1.478",
                latitude: String(location.coordinate.latitude + 0.015),
                longitude: String(location.coordinate.longitude - 0.02)
            ),
            GasStation(
                name: "Shell Select",
                town: "Getafe",
                municipality: "Madrid",
                schedule: "05:30 - 23:30",
                price: "1.445",
                latitude: String(location.coordinate.latitude - 0.01),
                longitude: String(location.coordinate.longitude - 0.01)
            ),
            GasStation(
                name: "Galp Energy",
                town: "Leganés",
                municipality: "Madrid",
                schedule: "24 horas",
                price: "1.412",
                latitude: String(location.coordinate.latitude + 0.008),
                longitude: String(location.coordinate.longitude + 0.025)
            ),
            GasStation(
                name: "Petronor Express",
                town: "Móstoles",
                municipality: "Madrid",
                schedule: "07:00 - 21:00",
                price: "1.435",
                latitude: String(location.coordinate.latitude - 0.005),
                longitude: String(location.coordinate.longitude + 0.008)
            )
        ]
    }
}
