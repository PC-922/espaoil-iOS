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
            // Icono de gasolinera
            Image(systemName: "fuelpump.fill")
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                // Nombre y comercializadora
                Text(gasStation.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                // Ubicación
                Text(gasStation.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Horario
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(gasStation.horario)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Distancia
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
            
            Spacer()
            
            // Precio
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
