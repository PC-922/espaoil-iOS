//
//  GasStationDTO.swift
//  EspaOil
//
//  Created by Jose E on 16/8/25.
//

import Foundation

struct GasStationDTO: Codable {
    let trader: String
    let name: String
    let town: String
    let municipality: String
    let schedule: String
    let price: String
    let latitude: String
    let longitude: String
}