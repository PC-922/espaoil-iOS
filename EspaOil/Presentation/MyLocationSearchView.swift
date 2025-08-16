//
//  ContentView.swift
//  Project01
//
//  Created by Jose E on 15/8/25.
//

import SwiftUI
import CoreLocation

struct MyLocationSearchView: View {
    @StateObject private var locationManager: LocationManager
    @StateObject private var gasStationService: GasStationService
    
    init(
        locationManager: LocationManager = LocationManager(),
        gasStationService: GasStationService = GasStationService()
    ) {
        self._locationManager = StateObject(wrappedValue: locationManager)
        self._gasStationService = StateObject(wrappedValue: gasStationService)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                Divider()
                if locationManager.isLoading {
                    loadingLocation
                } else if gasStationService.isLoadingStations {
                    loadingGasStations
                } else if !gasStationService.gasStations.isEmpty {
                    searchResultsView
                } else if locationManager.errorMessage != nil {
                    locationErrorView
                } else if gasStationService.errorMessage != nil {
                    gasStationErrorView
                } else {
                    emptyState
                }
            }
        }
        .onChange(of: locationManager.location) { oldValue, newLocation in
            if let location = newLocation {
                gasStationService.searchNearbyGasStations(location: location)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: locationManager.isLoading)
        .animation(.easeInOut(duration: 0.3), value: gasStationService.isLoadingStations)
        .animation(.easeInOut(duration: 0.3), value: gasStationService.gasStations.count)
    }
}

//MARK: - Views
private extension MyLocationSearchView {
    var header: some View {
        VStack {
            title
            fuelTypeSelector
            distanceThresholdField
            searchButton
            statusIndicator
        }
        .background(Color(.systemGroupedBackground))
    }
    
    var title: some View {
        Text("EspaOil")
            .font(.title3)
            .fontWeight(.bold)
    }
    
    var fuelTypeSelector: some View {
        HStack {
            Text("Tipo de combustible:")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Picker("Tipo de combustible", selection: $gasStationService.selectedFuelType) {
                ForEach(FuelType.allCases, id: \.self) { fuelType in
                    Text(fuelType.rawValue)
                        .tag(fuelType)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .font(.subheadline)
            .foregroundColor(.primary)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    var distanceThresholdField: some View {
        HStack {
            Text("Radio de búsqueda (km):")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            TextField("10", text: $gasStationService.searchRadiusKm)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .onChange(of: gasStationService.searchRadiusKm) { oldValue, newValue in
                    // Filtrar para permitir solo números y punto decimal
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    if filtered != newValue {
                        gasStationService.searchRadiusKm = filtered
                    }
                    // Actualizar la búsqueda si hay gasolineras cargadas
                    if !gasStationService.gasStations.isEmpty {
                        gasStationService.updateSearchRadius(filtered)
                    }
                }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    var searchButton: some View {
        Button(action: {
            locationManager.requestLocation()
        }) {
            HStack {
                if locationManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "location.fill")
                }
                Text(locationManager.isLoading ? "Obteniendo ubicación..." : "Buscar Gasolineras")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(locationManager.isLoading ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(locationManager.isLoading)
        .padding(.horizontal)
    }
    
    var statusIndicator: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
    }
    
    var loadingLocation: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Buscando tu ubicación...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    var loadingGasStations: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Buscando gasolineras cercanas...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
//            locationInfo
            sort
            gasStationList
        }
    }
    
    @ViewBuilder
    var locationInfo: some View {
        if let location = locationManager.location {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tu ubicación:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Lat: \(location.coordinate.latitude, specifier: "%.4f"), Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    var sort: some View {
        VStack(spacing: 12) {
            sortHeader
            HStack(spacing: 0) {
                sortOptions
                Spacer()
                sortDescriptionView
            }
        }
        .padding()
    }
    
    var sortHeader: some View {
        HStack {
            Text("Ordenar por:")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
    }
    
    var sortOptions: some View {
        HStack(spacing: 12) {
            ForEach(SortOption.allCases, id: \.self) { option in
                getOptionButton(option: option)
            }
        }
    }
    
    func getOptionButton(option: SortOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                gasStationService.updateSortOption(option)
            }
        }) {
            HStack {
                Text(option.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                gasStationService.sortOption == option
                    ? Color.blue
                    : Color(.systemGray5)
            )
            .foregroundColor(
                gasStationService.sortOption == option
                    ? .white
                    : .primary
            )
            .cornerRadius(8)
        }
    }
    
    var sortDescriptionView: some View {
        Text(sortDescription)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }

    var gasStationList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(gasStationService.gasStations) { station in
                    GasStationRow(
                        gasStation: station,
                        userLocation: locationManager.location
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fuelpump")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Encuentra Gasolineras")
                .font(.headline)
            
            Text("Presiona el botón para buscar las gasolineras más baratas cerca de ti")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var locationErrorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Ocurrió un error al obtener tu ubicación.")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var gasStationErrorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fuelpump.slash")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Ocurrió un error al buscar gasolineras.")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//MARK: - Computed Properties
private extension MyLocationSearchView {
    private var statusColor: Color {
        if locationManager.isLoading || gasStationService.isLoadingStations {
            return .orange
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    private var statusText: String {
        if locationManager.isLoading {
            return "Obteniendo ubicación..."
        } else if gasStationService.isLoadingStations {
            return "Buscando gasolineras..."
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Listo para buscar"
        case .denied, .restricted:
            return "Acceso denegado"
        case .notDetermined:
            return "Pendiente autorización"
        @unknown default:
            return "Estado desconocido"
        }
    }
    
    private var sortDescription: String {
        switch gasStationService.sortOption {
        case .price:
            return "(más baratas primero)"
        case .distance:
            return "(más cercanas primero)"
        }
    }
}

#Preview {
    MyLocationSearchView(gasStationService: .init(repository: MockGasStationRepository()))
}
