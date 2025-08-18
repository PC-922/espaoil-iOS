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
        .dismissKeyboardOnTap()
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
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .onChange(of: gasStationService.searchRadiusKm) { oldValue, newValue in
                    // Filtrar solo números y punto decimal
                    let filtered = newValue.filter { Constants.permittedCharacters.contains($0) }
                    
                    // Validar que el valor no esté vacío y sea un número válido
                    if filtered != newValue {
                        gasStationService.searchRadiusKm = filtered
                        return
                    }
                    
                    // Si el campo está vacío, no hacer nada más
                    guard !filtered.isEmpty else { return }
                    
                    // Validar que sea un número válido antes de procesar
                    if let radius = Double(filtered), radius.isFinite && radius > 0 {
                        // Solo actualizar si hay gasolineras cargadas
                        if !gasStationService.gasStations.isEmpty {
                            gasStationService.updateSearchRadius(filtered)
                        }
                    } else if !filtered.isEmpty {
                        // Si no es un número válido pero no está vacío, revertir al valor anterior
                        gasStationService.searchRadiusKm = oldValue
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
        static let appTitle = String(localized: "app.title")
        static let fuelTypeLabel = String(localized: "fuel.type.label")
        static let searchRadiusLabel = String(localized: "search.radius.label")
        static let gettingLocationText = String(localized: "location.getting")
        static let searchGasStationsButton = String(localized: "search.button")
        static let searchingLocationText = String(localized: "location.searching")
        static let searchingGasStationsText = String(localized: "gas.stations.searching")
        static let sortByLabel = String(localized: "sort.by.label")
        static let findGasStationsTitle = String(localized: "find.gas.stations.title")
        static let findGasStationsDescription = String(localized: "find.gas.stations.description")
        static let locationErrorText = String(localized: "error.location")
        static let gasStationErrorText = String(localized: "error.gas.stations")
        
        static let yourLocationText = String(localized: "location.your")
        static func coordinatesFormat(lat: Double, lon: Double) -> String {
            return String(localized: "coordinates.format \(String(format: "%.4f", lat)) \(String(format: "%.4f", lon))")
        }
        
        static let readyToSearchText = String(localized: "status.ready")
        static let accessDeniedText = String(localized: "status.denied")
        static let pendingAuthorizationText = String(localized: "status.pending")
        static let unknownStatusText = String(localized: "status.unknown")
        static let cheapestFirstText = String(localized: "sort.cheapest")
        static let nearestFirstText = String(localized: "sort.nearest")
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
