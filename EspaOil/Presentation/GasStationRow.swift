//
//  GasStationRow.swift
//  Project01
//
//  Created by Jose E on 15/8/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct GasStationRow: View {
    let gasStation: GasStation
    let userLocation: CLLocation?
    
    var body: some View {
        HStack(spacing: 12) {
            icon
            VStack(alignment: .leading, spacing: 4) {
                name
                fullAdress
                schedule
                distance
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                price
                mapButton
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(Constants.shadowOpacity), radius: Constants.shadowRadius, x: 0, y: 0)
    }
}

private extension GasStationRow {
    var icon: some View {
        Image(systemName: Constants.fuelPumpIcon)
            .foregroundColor(.accentColor)
            .font(.title2)
            .frame(width: Constants.iconWidth)
    }
    
    var name: some View {
        Text(gasStation.displayName)
            .font(.headline)
            .lineLimit(1)
    }
    
    var fullAdress: some View {
        Text(gasStation.fullAddress)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)
    }
    
    var schedule: some View {
        HStack {
            Image(systemName: Constants.clockIcon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(gasStation.schedule)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    var distance: some View {
        if let userLocation = userLocation {
            HStack {
                Image(systemName: Constants.locationIcon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(gasStation.formattedDistance(from: userLocation))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var price: some View {
        VStack(alignment: .trailing) {
            Text(gasStation.price)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(Localizables.priceUnit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var mapButton: some View {
        Button {
            openInMaps()
        } label: {
            Text(Localizables.openInMaps)
                .font(.caption)
        }
    }
    
    func openInMaps() {
        guard let latitude = Double(gasStation.latitude),
              let longitude = Double(gasStation.longitude) else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = gasStation.displayName
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

private extension GasStationRow {
    enum Localizables {
        static let priceUnit = "€/L"
        static let openInMaps = "Ver ruta en el mapa"
    }
    
    enum Constants {
        static let fuelPumpIcon = "fuelpump.fill"
        static let clockIcon = "clock"
        static let locationIcon = "location"
        static let shadowOpacity = 0.5
        static let shadowRadius: CGFloat = 1
        static let iconWidth: CGFloat = 30
    }
}

#Preview {
    GasStationRow(
        gasStation: GasStation(
            name: "Estación Repsol Centro",
            town: "Madrid",
            municipality: "Madrid",
            schedule: "24 horas",
            price: "1.459",
            latitude: "40.4168",
            longitude: "-3.7038"
        ),
        userLocation: CLLocation(latitude: 40.4168, longitude: -3.7038)
    )
    .padding()
}
