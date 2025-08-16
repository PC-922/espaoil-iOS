//
//  FuelType.swift
//  Project01
//
//  Created by Jose E on 16/8/25.
//

import Foundation

enum FuelType: String, CaseIterable {
    case gasoline95 = "Gasolina 95"
    case gasoline98 = "Gasolina 98"
    case diesel = "Gasoil"
    
    var displayName: String {
        return self.rawValue
    }
}
