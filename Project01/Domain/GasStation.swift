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
    let comercializadora: String
    let nombre: String
    let pueblo: String
    let municipio: String
    let horario: String
    let precio: String
    let latitud: String
    let longitud: String
    
    // Computed properties para facilitar el uso
    var priceDouble: Double {
        return Double(precio.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = Double(latitud.replacingOccurrences(of: ",", with: ".")),
              let lon = Double(longitud.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var displayName: String {
        return nombre.isEmpty ? comercializadora : nombre
    }
    
    var fullAddress: String {
        if pueblo.isEmpty {
            return municipio
        } else if pueblo == municipio {
            return municipio
        } else {
            return "\(pueblo), \(municipio)"
        }
    }
    
    // Calcular distancia desde una ubicación dada
    func distance(from location: CLLocation) -> Double? {
        guard let stationCoordinate = coordinate else { return nil }
        let stationLocation = CLLocation(latitude: stationCoordinate.latitude, longitude: stationCoordinate.longitude)
        return location.distance(from: stationLocation)
    }
    
    // Formato de distancia legible
    func formattedDistance(from location: CLLocation) -> String {
        guard let distance = distance(from: location) else { return "Distancia desconocida" }
        
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
                comercializadora: "Repsol",
                nombre: "Estación Repsol Centro",
                pueblo: "Madrid",
                municipio: "Madrid",
                horario: "24 horas",
                precio: "1.459",
                latitud: String(location.coordinate.latitude + 0.01),
                longitud: String(location.coordinate.longitude + 0.01)
            ),
            GasStation(
                comercializadora: "Cepsa",
                nombre: "Cepsa Express",
                pueblo: "Madrid",
                municipio: "Madrid",
                horario: "06:00 - 22:00",
                precio: "1.425",
                latitud: String(location.coordinate.latitude - 0.02),
                longitud: String(location.coordinate.longitude + 0.015)
            ),
            GasStation(
                comercializadora: "BP",
                nombre: "BP Station",
                pueblo: "Alcorcón",
                municipio: "Madrid",
                horario: "24 horas",
                precio: "1.478",
                latitud: String(location.coordinate.latitude + 0.015),
                longitud: String(location.coordinate.longitude - 0.02)
            ),
            GasStation(
                comercializadora: "Shell",
                nombre: "Shell Select",
                pueblo: "Getafe",
                municipio: "Madrid",
                horario: "05:30 - 23:30",
                precio: "1.445",
                latitud: String(location.coordinate.latitude - 0.01),
                longitud: String(location.coordinate.longitude - 0.01)
            ),
            GasStation(
                comercializadora: "Galp",
                nombre: "Galp Energy",
                pueblo: "Leganés",
                municipio: "Madrid",
                horario: "24 horas",
                precio: "1.412",
                latitud: String(location.coordinate.latitude + 0.008),
                longitud: String(location.coordinate.longitude + 0.025)
            ),
            GasStation(
                comercializadora: "Petronor",
                nombre: "Petronor Express",
                pueblo: "Móstoles",
                municipio: "Madrid",
                horario: "07:00 - 21:00",
                precio: "1.435",
                latitud: String(location.coordinate.latitude - 0.005),
                longitud: String(location.coordinate.longitude + 0.008)
            )
        ]
    }
}
