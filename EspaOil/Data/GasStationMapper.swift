//
//  GasStationMapper.swift
//  EspaOil
//
//  Created by Jose E on 16/8/25.
//

import Foundation

struct GasStationMapper {
    
    static func toDomain(from dto: GasStationDTO) -> GasStation? {
        // Validar que los datos críticos no estén vacíos o sean inválidos
        guard !dto.name.isEmpty,
              !dto.price.isEmpty,
              !dto.latitude.isEmpty,
              !dto.longitude.isEmpty else {
            return nil
        }
        
        // Validar que las coordenadas sean números válidos
        let latString = dto.latitude.replacingOccurrences(of: ",", with: ".")
        let lonString = dto.longitude.replacingOccurrences(of: ",", with: ".")
        
        guard let lat = Double(latString),
              let lon = Double(lonString),
              lat.isFinite && lon.isFinite,
              abs(lat) <= 90.0 && abs(lon) <= 180.0 else {
            return nil
        }
        
        // Validar que el precio sea un número válido
        let priceString = dto.price.replacingOccurrences(of: ",", with: ".")
        guard let price = Double(priceString),
              price.isFinite && price >= 0 else {
            return nil
        }
        
        return GasStation(
            name: dto.name,
            town: dto.town,
            municipality: dto.municipality,
            schedule: dto.schedule,
            price: dto.price,
            latitude: dto.latitude,
            longitude: dto.longitude
        )
    }
    
    static func toDomainList(from dtos: [GasStationDTO]) -> [GasStation] {
        return dtos.compactMap { toDomain(from: $0) }
    }
}
