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
            #if DEBUG
            Tab(Localizables.environmentTabTitle, systemImage: Constants.environmentIcon) {
                EnvironmentConfigView()
            }
            #endif
            Tab(Localizables.aboutTabTitle, systemImage: Constants.aboutIcon) {
                InfoView()
            }
        }
    }
}

private extension TabBarView {
    enum Localizables {
        static let homeTabTitle = String(localized: "tab.search")
        static let aboutTabTitle = String(localized: "tab.about")
        static let environmentTabTitle = String(localized: "tab.environment")
    }
    
    enum Constants {
        static let homeIcon = "house.fill"
        static let aboutIcon = "questionmark.circle.fill"
        static let environmentIcon = "gearshape.fill"
    }
}

#Preview {
    TabBarView()
}
