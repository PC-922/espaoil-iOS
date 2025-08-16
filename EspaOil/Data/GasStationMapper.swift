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
            comercializadora: dto.trader,
            nombre: dto.name,
            pueblo: dto.town,
            municipio: dto.municipality,
            horario: dto.schedule,
            precio: dto.price,
            latitud: dto.latitude,
            longitud: dto.longitude
        )
    }
    
    static func toDomainList(from dtos: [GasStationDTO]) -> [GasStation] {
        return dtos.map { toDomain(from: $0) }
    }
}