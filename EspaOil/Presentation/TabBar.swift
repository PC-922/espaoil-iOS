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
            Tab("Inicio", systemImage: "house.fill") {
                MyLocationSearchView()
            }
            Tab("About", systemImage: "questionmark.circle.fill") {
                Text("PC 922")
            }
        }
    }
}

#Preview {
    TabBarView()
}
