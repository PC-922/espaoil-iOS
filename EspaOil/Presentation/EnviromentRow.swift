//
//  EnviromentRow.swift
//  EspaOil
//
//  Created by Jose E on 17/8/25.
//

import SwiftUI

struct EnvironmentRow: View {
    let environment: AppEnvironment
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(environment.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(environment.baseURL)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                        .font(.body)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
