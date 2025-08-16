//
//  SortOption.swift
//  Project01
//
//  Created by Jose E on 16/8/25.
//

import Foundation

enum SortOption: CaseIterable {
    case price
    case distance
    
    var displayName: String {
        switch self {
        case .price:
            return "Precio"
        case .distance:
            return "Distancia"
        }
    }
}
