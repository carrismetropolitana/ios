//
//  StopsView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI
import MapKit

struct StopsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var vehiclesManager: VehiclesManager
    @EnvironmentObject var stopsManager: StopsManager
    
    @State private var isSheetPresented = false
    
    @State private var searchTerm = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching = false
    @State private var searchFilteredStops: [Stop] = []
    
    @State var shouldPresentStopDetailsView = false
    @State var shouldPresentVehicleDetailsView = false
    @State var vehicleIdToBePresented: String? = nil

//    @State private var stops: [Stop] = []
    @State private var selectedStopId: String?
    
    var body: some View {
        let suggestedStops = locationManager.location != nil ? closestStops(to: locationManager.location!, stops: stopsManager.stops, maxResults: 10) : Array(stopsManager.stops.prefix(10))
        NavigationStack {
            ZStack {
                if let stop = stopsManager.stops.first(where: {$0.id == selectedStopId}) {
                    NavigationLink(destination: StopDetailsView(stop: stop), isActive: $shouldPresentStopDetailsView) { EmptyView() }
                }
                
                if let vehicleId = vehicleIdToBePresented {
//                    if vehiclesManager.vehicles.contains({$0.id == vehicleId}) {
                        NavigationLink(destination: VehicleDetailsView(vehicleId: vehicleId), isActive: $shouldPresentVehicleDetailsView) { EmptyView() }
//                    }
                }
                
                MapLibreMapView(stops: stopsManager.stops, selectedStopId: $selectedStopId)
                    .ignoresSafeArea()
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Spacer()
                        MapFloatingButton(systemImage: "line.3.horizontal.decrease.circle")
                        MapFloatingButton(systemImage: "location.fill")
                        MapFloatingButton(systemImage: "map")
                    }
                }
                .padding()
                
                if (isSearching) {
                   searchResultsOverlay()
                }
                
                searchBar()
                
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
            .onChange(of: stopsManager.stops) {
                if stopsManager.stops.count > 0 {
                    searchFilteredStops = suggestedStops
                    print("suggested: \(suggestedStops.count)")
                    print("initfilteredshouldbeequaltosuggested: \(searchFilteredStops.count)")
                }
            }
            .onChange(of: isSearchFieldFocused) {
                withAnimation {
                    isSearching = isSearchFieldFocused
                }
                
                if (!isSearchFieldFocused) {
                    searchTerm = ""
                }
            }
            .onChange(of: searchTerm) {
                print(searchTerm)
                let filtered = stopsManager.stops.chunkedFilter({
                    $0.name.localizedCaseInsensitiveContains(searchTerm) || $0.id.localizedCaseInsensitiveContains(searchTerm)
                }, maxResults: 10)
                if filtered.count > 0 {
                    searchFilteredStops = filtered
                } else {
                    searchFilteredStops = suggestedStops
                }
            }
            .onChange(of: selectedStopId) {
                if selectedStopId != "" { // avoid trigger on sheet dismiss; TODO: @see line #67
                    isSheetPresented.toggle()
                    print("Changed stopId to \(String(describing: selectedStopId))")
                }
            }
            .onChange(of: shouldPresentStopDetailsView) {
                if shouldPresentStopDetailsView { // do not open sheet on return from stopdetails view
                    isSheetPresented.toggle()
                }
            }
            .onChange(of: vehicleIdToBePresented) {
                if let _ = vehicleIdToBePresented {
                    shouldPresentVehicleDetailsView.toggle()
                    isSheetPresented.toggle()
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    if let stop = stopsManager.stops.first(where: {$0.id == selectedStopId}) {
                        StopDetailsSheetView(shouldPresentStopDetailsView: $shouldPresentStopDetailsView, onEtaClick: { vehicleId in
                            print("got vehid from etas sheet on parent; vid: \(vehicleId)")
                            vehicleIdToBePresented = vehicleId
                        }, stop: stop)
                    }
                }
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationDetents([.fraction(0.5)])
                .onDisappear {
                    selectedStopId = "" // TODO: (fixme) empty string because mapView checks for nil
                }
        }
        }
    }
    
    private func searchBar() -> some View {
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
                    .fill(.white)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    
    private func searchResultsOverlay() -> some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
            .ignoresSafeArea()
            .onTapGesture {
                isSearchFieldFocused = false
            }
            
            ScrollView {
                VStack {
                    ForEach(searchFilteredStops) { stop in
                        Button {} label: {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
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

#Preview {
    StopsView()
}

struct MapFloatingButton: View {
    let systemImage: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0)
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .shadow(color: .black.opacity(0.2), radius: 10)
            Image(systemName: systemImage)
                .resizable()
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
        }
    }
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
