//
//  GasStationRow.swift
//  Project01
//
//  Created by Jose E on 15/8/25.
//

import SwiftUI
import CoreLocation

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
            price
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0)
    }
}

private extension GasStationRow {
    var icon: some View {
        Image(systemName: "fuelpump.fill")
            .foregroundColor(.blue)
            .font(.title2)
            .frame(width: 30)
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
            Image(systemName: "clock")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(gasStation.horario)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    var distance: some View {
        if let userLocation = userLocation {
            HStack {
                Image(systemName: "location")
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
            Text(gasStation.precio)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text("€/L")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    GasStationRow(
        gasStation: GasStation(
            comercializadora: "Repsol",
            nombre: "Estación Repsol Centro",
            pueblo: "Madrid",
            municipio: "Madrid",
            horario: "24 horas",
            precio: "1.459",
            latitud: "40.4168",
            longitud: "-3.7038"
        ),
        userLocation: CLLocation(latitude: 40.4168, longitude: -3.7038)
    )
    .padding()
}
