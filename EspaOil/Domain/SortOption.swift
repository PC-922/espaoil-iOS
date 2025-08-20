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
    
    var displayName: String.LocalizationValue {
        switch self {
        case .price:
            return "sort.option.price"
        case .distance:
            return "sort.option.distance"
        }
    }
}
