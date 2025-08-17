//
//  EnvironmentConfigView.swift
//  EspaOil
//
//  Created by Jose E on 17/8/25.
//

import SwiftUI

struct EnvironmentConfigView: View {
    @State private var selectedEnvironment = AppConfiguration.shared.currentEnvironment
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Localizables.currentEnvironmentLabel)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(selectedEnvironment.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(selectedEnvironment.baseURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(Localizables.environmentSectionHeader)
                }
                
                Section {
                    ForEach(AppEnvironment.allCases, id: \.self) { environment in
                        EnvironmentRow(
                            environment: environment,
                            isSelected: selectedEnvironment == environment
                        ) {
                            selectedEnvironment = environment
                            AppConfiguration.shared.currentEnvironment = environment
                            showingAlert = true
                        }
                    }
                } header: {
                    Text(Localizables.availableEnvironmentsHeader)
                } footer: {
                    Text(Localizables.environmentFooterNote)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: Constants.infoIcon)
                                .foregroundColor(.blue)
                            Text(Localizables.debugInfoTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text(Localizables.debugInfoDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(Localizables.debugSectionHeader)
                }
            }
            .navigationTitle(Localizables.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(Localizables.environmentChangedTitle, isPresented: $showingAlert) {
            Button(Localizables.okButton) { }
        } message: {
            Text(Localizables.environmentChangedMessage)
        }
    }
}

private extension EnvironmentConfigView {
    enum Localizables {
        static let navigationTitle = String(localized: "environment.config.title")
        static let currentEnvironmentLabel = String(localized: "environment.current.label")
        static let environmentSectionHeader = String(localized: "environment.section.header")
        static let availableEnvironmentsHeader = String(localized: "environment.available.header")
        static let environmentFooterNote = String(localized: "environment.footer.note")
        static let debugSectionHeader = String(localized: "environment.debug.header")
        static let debugInfoTitle = String(localized: "environment.debug.title")
        static let debugInfoDescription = String(localized: "environment.debug.description")
        static let environmentChangedTitle = String(localized: "environment.changed.title")
        static let environmentChangedMessage = String(localized: "environment.changed.message")
        static let okButton = String(localized: "button.ok")
    }
    
    enum Constants {
        static let infoIcon = "info.circle"
    }
}

#Preview {
    EnvironmentConfigView()
}
