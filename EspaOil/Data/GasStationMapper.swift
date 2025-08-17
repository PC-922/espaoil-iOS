//
//  GasStationMapper.swift
//  EspaOil
//
//  Created by Jose E on 16/8/25.
//

import Foundation

struct GasStationMapper {
    
    static func toDomain(from dto: GasStationDTO) -> GasStation {
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
        return dtos.map { toDomain(from: $0) }
    }
}
