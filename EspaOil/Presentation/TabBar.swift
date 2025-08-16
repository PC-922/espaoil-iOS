//
//  TabBar.swift
//  Project01
//
//  Created by Jose E on 16/8/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            Tab(Localizables.homeTabTitle, systemImage: Constants.homeIcon) {
                MyLocationSearchView()
            }
            Tab(Localizables.aboutTabTitle, systemImage: Constants.aboutIcon) {
                Text(Localizables.aboutContent)
            }
        }
    }
}

private extension TabBarView {
    enum Localizables {
        static let homeTabTitle = "Inicio"
        static let aboutTabTitle = "About"
        static let aboutContent = "PC 922"
    }
    
    enum Constants {
        static let homeIcon = "house.fill"
        static let aboutIcon = "questionmark.circle.fill"
    }
}

#Preview {
    TabBarView()
}
