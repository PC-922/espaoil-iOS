//
//  AboutView.swift
//  EspaOil
//
//  Created by Jose E on 22/8/25.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(spacing: 44) {
            Spacer()
            header
            VStack {
                dataSourceAtribution
                dataUpdates
            }
            Spacer()
        }
    }
}

private extension InfoView {
    var header: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                Text(Localizables.appTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
    
    var dataSourceAtribution: some View {
        Text(Localizables.dataSourceAttribution)
        .font(.callout)
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    var dataUpdates: some View {
        Text(Localizables.dataUpdates)
        .font(.callout)
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

private extension InfoView {
    enum Localizables {
        static let appTitle = String(localized: "app.title")
        static let dataSourceAttribution = String(localized: "info.data.source.attribution")
        static let dataUpdates = String(localized: "info.data.updates")
    }
}

#Preview {
    InfoView()
}
