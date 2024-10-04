//
//  StopsView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI
import MapKit

struct StopsView: View {
    @EnvironmentObject var tabCoordinator: TabCoordinator
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var vehiclesManager: VehiclesManager
    @EnvironmentObject var stopsManager: StopsManager
    @EnvironmentObject var linesManager: LinesManager
    
    @State private var isSheetPresented = false
    @State private var sheetHeight: CGFloat = .zero
    
    @State private var searchTerm = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching = false
    @State private var searchFilteredStops: [Stop] = []
    @State private var suggestedStops: [Stop] = []
    
    @State var shouldPresentStopDetailsView = false
    @State var shouldPresentVehicleDetailsView = false
    @State var vehicleIdToBePresented: String? = nil
    
    //    @State private var stops: [Stop] = []
    @State private var selectedStopId: String?
    
    @State private var flyToCoords: CLLocationCoordinate2D? = nil
    @State private var mapFlyToUserCoords = false
    
    @State private var isErrorBannerPresented = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    @State private var lineIdToBePresented: String? = nil
    @State private var patternIdToBePresented: String? = nil
    @State private var shouldPresentLineDetailsView = false
    
    @State private var mapVisualStyle: MapVisualStyle = .standard
    
    @State private var mapVisible: Bool = true
    
    @State private var seeAllNextEtas = false
//    @State private var sheetPresentationDetents: [PresentationDetent] = [.fraction(0.5)]
    
    var body: some View {
        var suggestedStops = locationManager.location != nil ? closestStops(to: locationManager.location!.coordinate, stops: stopsManager.stops, maxResults: 10) : Array(stopsManager.stops.prefix(10))
        NavigationStack {
            ZStack {
                if let stop = stopsManager.stops.first(where: {$0.id == selectedStopId}) {
                    NavigationLink(
                        destination: 
                            StopDetailsView(stop: stop, mapFlyToCoords: $flyToCoords)
                                .onDisappear { if mapVisible { isSheetPresented = true } }
                                .onAppear { if mapVisible { isSheetPresented = false} },
                        isActive: $shouldPresentStopDetailsView
                    ) { EmptyView() }
                }
                
                if let vehicleId = vehicleIdToBePresented {
                    //                    if vehiclesManager.vehicles.contains({$0.id == vehicleId}) {
                    NavigationLink(
                        destination: 
                            VehicleDetailsView(vehicleId: vehicleId)
                            .onDisappear { if mapVisible { isSheetPresented = true; vehicleIdToBePresented = nil } }
                                .onAppear { if mapVisible { isSheetPresented = false} },
                        isActive: $shouldPresentVehicleDetailsView
                    ) { EmptyView() }
                    //                    }
                }
                
                if let lineId = lineIdToBePresented, let patternId = patternIdToBePresented {
                    NavigationLink(
                        destination: 
                            LineDetailsView(
                                line: linesManager.lines.first { $0.id == lineId }!,
                                overrideDisplayedPatternId: patternId)
                                    .onDisappear { if mapVisible { isSheetPresented = true; lineIdToBePresented = nil } }
                                    .onAppear { if mapVisible { isSheetPresented = false} },
                        isActive: $shouldPresentLineDetailsView
                    ) { EmptyView() }
                }
                
                StopsMapView(
                    stops: stopsManager.stops,
                    onStopSelect: { stopId in
                        selectedStopId = stopId
                        isSheetPresented = true
                        print("Changed stopId to \(String(describing: selectedStopId))")
                    },
                    flyToCoords: flyToCoords,
                    shouldFlyToUserCoords: $mapFlyToUserCoords,
                    mapVisualStyle: mapVisualStyle
                ).ignoresSafeArea().onDisappear {
                    mapVisible = false
                }.onAppear {
                    mapVisible = true
                }
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Spacer()
                        
//                        MapFloatingButton(systemImage: "line.3.horizontal.decrease.circle")
                        
                        MapFloatingButton(systemImage: "location.fill")  {
                            if let _ = locationManager.location {
                                mapFlyToUserCoords = true
                            }
                        }
                        
                        MapFloatingPickerMenu(systemImage: "map", selection: $mapVisualStyle, options: MapVisualStyle.allCases.reversed() /* ? */) { style in
                            getMapVisualStyleString(for: style)
                        }
                    }
                }
                .padding()
                
                if (isSearching) {
                    searchResultsOverlay
                }
                
                searchBar
                
            }
            //            .onAppear {
            //                if stops.count == 0 {
            //                    Task {
            //                        stops = await CMAPI.shared.getStops()
            //                        print(stops.count)
            //                    }
            //                }
            ////                if shouldPresentStopDetailsView {
            ////                    shouldPresentStopDetailsView = false
            ////                }
            //            }
//            .onChange(of: locationManager.location) {
//                if stopsManager.stops.count > 0 {
//                    if let location = locationManager.location {
//                        closestStopsToUser = closestStops(to: locationManager.location!, stops: stopsManager.stops, maxResults: 10)
//                    }
//                }
//            }
            .onChange(of: mapFlyToUserCoords) {
                print("map flying to user coords")
            }
            .onChange(of: stopsManager.stops) {
                if stopsManager.stops.count > 0 {
                    if let location = locationManager.location {
                        suggestedStops = closestStops(to: location.coordinate, stops: stopsManager.stops, maxResults: 10)
                    } else {
                        suggestedStops = Array(stopsManager.stops.prefix(10))
//                        print("suggested: \(suggestedStops.count)")
//                        print("initfilteredshouldbeequaltosuggested: \(searchFilteredStops.count)")
                    }
                    
                    searchFilteredStops = suggestedStops
                }
            }
            
            
            .onChange(of: isSearchFieldFocused) {
                print("Search field focused, suggested stops count is \(suggestedStops.count)")
                withAnimation(.smooth(duration: 0.3)) {
                    isSearching = isSearchFieldFocused
                }
                
                if (!isSearchFieldFocused) {
                    searchTerm = ""
                }
            }
            
            
            .onChange(of: searchTerm) {
                print(searchTerm)
                let t1 = Date().timeIntervalSince1970
                
                let stops = stopsManager.stops
                let normalizedSearchTerm = searchTerm.normalizedForSearch()
                let filtered = stops.filter({
                    $0.name.normalizedForSearch().contains(normalizedSearchTerm)
                    || $0.id.normalizedForSearch().contains(normalizedSearchTerm)
                    || ($0.ttsName != nil && $0.ttsName!.normalizedForSearch().contains(normalizedSearchTerm))
                })
                
                let t2 = Date().timeIntervalSince1970
                
                print("SEARCH TOOK \(t2-t1)s")
                
                if filtered.count > 0 {
                    searchFilteredStops = filtered
                } else {
                    searchFilteredStops = suggestedStops
                }
            }
            
            
            
            // cant do this like this because when people click the same stop it doesnt change lol and we need to keep that state for when user returns from submenus
//            .onChange(of: selectedStopId) {
//                print("changed stopid \(selectedStopId)")
//                if selectedStopId != "" { // avoid trigger on sheet dismiss; TODO: @see line #67
//                    isSheetPresented.toggle()
//                    print("Changed stopId to \(String(describing: selectedStopId))")
//                }
//            }
//            .onChange(of: shouldPresentStopDetailsView) {
////                if shouldPresentStopDetailsView { // do not open sheet on return from stopdetails view
//                    isSheetPresented.toggle()
////                }
//            }
            .onChange(of: vehicleIdToBePresented) {
                if let _ = vehicleIdToBePresented {
                    shouldPresentVehicleDetailsView.toggle()
                }
            }
            .onChange(of: lineIdToBePresented) {
                if let _ = lineIdToBePresented {
                    shouldPresentLineDetailsView.toggle()
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    if let stop = stopsManager.stops.first(where: {$0.id == selectedStopId}) {
                        StopDetailsSheetView(shouldPresentStopDetailsView: $shouldPresentStopDetailsView, onEtaClick: { eta in
                            print("ETA Clicked, VID is \(eta.vehicleId)")
                            if let vehicleId = eta.vehicleId {
                                if vehiclesManager.vehicles.contains(where: { $0.id == vehicleId }) {
                                    vehicleIdToBePresented = vehicleId
                                } else {
                                    errorTitle = "O veículo não está disponível."
                                    errorMessage = "Por favor tente mais tarde."
                                    isErrorBannerPresented = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        withAnimation {
                                            isErrorBannerPresented = false
                                        }
                                    }
                                }
                            } else { // if no realtime available
                                patternIdToBePresented = eta.patternId
                                lineIdToBePresented = eta.lineId
                                isSheetPresented = true
                                print("\(patternIdToBePresented) :: \(lineIdToBePresented)")
                            }
                        }, stop: stop, seeAllNextEtas: $seeAllNextEtas)
                    }
                }
//                .readHeight()
//                .onPreferenceChange(HeightPreferenceKey.self) { height in
//                    if let height {
//                        sheetHeight = height
//                    }
//                }
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationDetents([.fraction(0.5)])
//                .presentationDetents(sheetPresentationDetents)
//                .presentationDetents([.height(sheetHeight)])
//                .onDisappear {
                    // selectedStopId = "" // TODO: (fixme) empty string because mapView checks for nil
//                }
            }
//            .onChange(of: seeAllNextEtas) {
//                if seeAllNextEtas {
//                    sheetPresentationDetents.append(.large)
//                }
//            }
            .errorBanner(isPresented: $isErrorBannerPresented, title: $errorTitle, message: $errorMessage)
            .onAppear {
                vehiclesManager.stopFetching()
                print("From stops view, external tab send mapflytocoords: \(tabCoordinator.mapFlyToCoords)")
                if let flyToCoordsFromExternalTab = tabCoordinator.mapFlyToCoords,
                   let flownToStopIdFromExternalTab = tabCoordinator.flownToStopId {
                    DispatchQueue.main.async {
                        flyToCoords = flyToCoordsFromExternalTab
                        selectedStopId = flownToStopIdFromExternalTab
                        isSheetPresented = true
                    }
                }
            }
        }
    }
    
    var searchBar: some View {
        VStack {
            HStack(alignment: .center) {
                if (!isSearching) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .bold()
                        .padding(.vertical, 18)
                        .padding(.leading, 18)
                        .onTapGesture {
                            isSearchFieldFocused = true
                        }
                }
                TextField("", text: $searchTerm, prompt: Text("Nome ou número da paragem").foregroundColor(.gray).fontWeight(.semibold))
                    .padding(.leading, isSearching ? 18 : 0)
                
                    .frame(height: 50)
                    .focused($isSearchFieldFocused)
                //                            .background(.red)
                if (isSearching) {
                    Button {
                        isSearchFieldFocused = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                            .bold()
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 18)
                    .padding(.trailing, 18)
                }
            }
            .background {
                //                        if (isSearching) { // needs to be here to avoid background tap gesture taking precedence over backgrounded views's gestures
                //                            RoundedRectangle(cornerRadius: 15.0)
                //                                .fill(.white)
                //                        } else {
                //                            RoundedRectangle(cornerRadius: 15.0)
                //                                .fill(.white)
                //                                .onTapGesture {
                //                                    isSearchFieldFocused = true
                //                                }
                //                        }
                RoundedRectangle(cornerRadius: 15.0)
                    .fill(.cmListItemBackground)
            }
            Spacer()
        }
        .padding(.horizontal)
        .overlay {
            if (!isSearching) {
                Color.clear.onTapGesture {
                    isSearchFieldFocused = true
                }
            }
        }
    }
    
    
    var searchResultsOverlay: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    isSearchFieldFocused = false
                }
            ScrollView {
                LazyVStack {
                    ForEach(searchFilteredStops) { stop in
                        Button {
                            flyToCoords = CLLocationCoordinate2D(latitude: Double(stop.lat)!, longitude: Double(stop.lon)!)
                            isSearching = false
                            isSearchFieldFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                selectedStopId = stop.id
                            }
                        } label: {
                            StopSearchResultEntry(stop: stop)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            Text("Paragem número \(stop.id.map { String($0) }.joined(separator: " ")), \(stop.ttsName ?? stop.name)", comment: "Paragem resultado de pesquisa")
                        )
                    }
                }
                
            }
            .contentMargins(.top, 70, for: .scrollContent)
        }
    }
    
}

struct StopSearchResultEntry: View {
    let stop: Stop
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(.cmListItemBackground)
            .frame(height: 80.0)
            .overlay {
                HStack {
                    Circle()
                        .fill(.black)
                        .frame(height: 20)
                        .overlay {
                            Circle()
                                .fill(.cmYellow)
                                .frame(height: 15)
                        }
                        .padding()
                    VStack(alignment:. leading) {
                        Text(stop.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(stop.locality == stop.municipalityName || stop.locality == nil ? stop.municipalityName : "\(stop.locality!), \(stop.municipalityName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(stop.id)
                            .font(.custom("Menlo", size: 12.0).monospacedDigit())
                            .bold()
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 10)
                            .background(Capsule().stroke(.gray, lineWidth: 2.0))
                            .padding(.vertical, 2.0)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .padding(.trailing)
                }
            }
    }
}

#Preview {
    StopsView()
}

extension Array {
    func chunkedFilter(_ isIncluded: @escaping (Element) -> Bool, chunkSize: Int = 1000, maxResults: Int) -> [Element] {
        print("Chunked ARR Filter Start:: \(Date.now)")
        let queue = DispatchQueue(label: "pt.carrismetropolitana.chunkedFilter", attributes: .concurrent)
        let group = DispatchGroup()
        
        var filteredElements: [Element] = []
        let lock = NSLock()
        var isDone = false
        
        for chunk in stride(from: 0, to: self.count, by: chunkSize) {
            if isDone { break }
            let end = Swift.min(chunk + chunkSize, self.count)
            group.enter()
            queue.async {
                let chunkFiltered = self[chunk..<end].filter(isIncluded)
                lock.lock()
                if !isDone {
                    filteredElements.append(contentsOf: chunkFiltered)
                    if filteredElements.count >= maxResults {
                        filteredElements = Array(filteredElements.prefix(maxResults))
                        isDone = true
                    }
                }
                lock.unlock()
                group.leave()
            }
        }
        
        group.wait()
        print("Chunked ARR Filter return, end:: \(Date.now)")
        return filteredElements
    }
}
