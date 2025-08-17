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
        content
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
    
    var content: some View {
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
        Text(Localizables.appTitle)
            .font(.title3)
            .fontWeight(.bold)
    }
    
    var fuelTypeSelector: some View {
        HStack {
            Text(Localizables.fuelTypeLabel)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Picker(Localizables.fuelTypeLabel, selection: $gasStationService.selectedFuelType) {
                ForEach(FuelType.allCases, id: \.self) { fuelType in
                    Text(fuelType.displayName)
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
            Text(Localizables.searchRadiusLabel)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            TextField(Constants.defaultSearchRadius, text: $gasStationService.searchRadiusKm)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .onChange(of: gasStationService.searchRadiusKm) { oldValue, newValue in
                    let filtered = newValue.filter { Constants.permittedCharacters.contains($0) }
                    if filtered != newValue {
                        gasStationService.searchRadiusKm = filtered
                    }
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
                    Image(systemName: Constants.locationIcon)
                }
                Text(locationManager.isLoading ? Localizables.gettingLocationText : Localizables.searchGasStationsButton)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(locationManager.isLoading ? Color.gray : Color.accentColor)
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
            Text(Localizables.searchingLocationText)
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
            Text(Localizables.searchingGasStationsText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            sort
            gasStationList
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
            Text(Localizables.sortByLabel)
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
                    ? Color.accentColor
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
            Image(systemName: Constants.fuelPumpIcon)
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
            
            Text(Localizables.findGasStationsTitle)
                .font(.headline)
            
            Text(Localizables.findGasStationsDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var locationErrorView: some View {
        VStack(spacing: 16) {
            Image(systemName: Constants.exclamationTriangleIcon)
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text(Localizables.locationErrorText)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    var gasStationErrorView: some View {
        VStack(spacing: 16) {
            Image(systemName: Constants.fuelPumpSlashIcon)
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text(Localizables.gasStationErrorText)
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
            return Localizables.gettingLocationText
        } else if gasStationService.isLoadingStations {
            return Localizables.searchingGasStationsText
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return Localizables.readyToSearchText
        case .denied, .restricted:
            return Localizables.accessDeniedText
        case .notDetermined:
            return Localizables.pendingAuthorizationText
        @unknown default:
            return Localizables.unknownStatusText
        }
    }
    
    private var sortDescription: String {
        switch gasStationService.sortOption {
        case .price:
            return Localizables.cheapestFirstText
        case .distance:
            return Localizables.nearestFirstText
        }
    }
}

private extension MyLocationSearchView {
    enum Localizables {
        static let appTitle = "EspaOil"
        static let fuelTypeLabel = "Tipo de combustible:"
        static let searchRadiusLabel = "Radio de búsqueda (km):"
        static let gettingLocationText = "Obteniendo ubicación..."
        static let searchGasStationsButton = "Buscar Gasolineras"
        static let searchingLocationText = "Buscando tu ubicación..."
        static let searchingGasStationsText = "Buscando gasolineras cercanas..."
        static let sortByLabel = "Ordenar por:"
        static let findGasStationsTitle = "Encuentra Gasolineras"
        static let findGasStationsDescription = "Presiona el botón para buscar las gasolineras más baratas cerca de ti"
        static let locationErrorText = "Ocurrió un error al obtener tu ubicación."
        static let gasStationErrorText = "Ocurrió un error al buscar gasolineras."
        
        static let yourLocationText = "Tu ubicación:"
        static func coordinatesFormat(lat: Double, lon: Double) -> String {
            return "Lat: \(String(format: "%.4f", lat)), Lon: \(String(format: "%.4f", lon))"
        }
        
        static let readyToSearchText = "Listo para buscar"
        static let accessDeniedText = "Acceso denegado"
        static let pendingAuthorizationText = "Pendiente autorización"
        static let unknownStatusText = "Estado desconocido"
        static let cheapestFirstText = "(más baratas primero)"
        static let nearestFirstText = "(más cercanas primero)"
    }
    
    enum Constants {
        static let permittedCharacters = "0123456789."
        static let defaultSearchRadius = "10"
        static let locationIcon = "location.fill"
        static let fuelPumpIcon = "fuelpump"
        static let exclamationTriangleIcon = "exclamationmark.triangle"
        static let fuelPumpSlashIcon = "fuelpump.slash"
    }
}

#Preview {
    MyLocationSearchView(gasStationService: .init(repository: MockGasStationRepository()))
}
