//
//  FuelType.swift
//  Project01
//
//  Created by Jose E on 16/8/25.
//

import Foundation

enum FuelType: String, CaseIterable {
    case gasoline95E5 = "95 E5"
    case gasoline95E5Premium = "95 E5 Premium"
    case gasoline95E10 = "95 E10"
    case gasoline98E5 = "98 E5"
    case gasoline98E10 = "98 E10"
    case gasoilA = "Gasoil A"
    case gasoilB = "Gasoil B"
    case gasoilPremium = "Gasoil Premium"
    case biodiesel = "Biodiesel"
    case bioethanol = "Bioetanol"
    case naturalGasCompressed = "Gas Natural Comprimido"
    case naturalGasLiquefied = "Gas Natural Licuado"
    case lpg = "Gases licuados del petróleo"
    case hydrogen = "Hidrógeno"
}
