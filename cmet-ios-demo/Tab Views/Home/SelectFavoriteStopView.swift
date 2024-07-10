//
//  FavoriteStopCustomizationView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 30/06/2024.
//

import SwiftUI

struct SelectFavoriteStopView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var stopsManager: StopsManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @State private var suggestedStops: [Stop] = []
    
    @Binding var selectedStopId: String?
    
    
    @State private var searchTerm = ""
    
    var body: some View {
        VStack {
            MapLibreMapView(stops: stopsManager.stops, selectedStopId: .constant(nil), flyToCoords: .constant(nil))
                .frame(height: 300)
            
            List {
                ForEach(suggestedStops) { stop in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stop.name)
                            
                            Text(stop.locality == stop.municipalityName || stop.locality == nil ? stop.municipalityName : "\(stop.locality!), \(stop.municipalityName)")
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            selectedStopId = stop.id
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                                .scaleEffect(1.3)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .searchable(text: $searchTerm, prompt: "Nome ou número da paragem")
        }
        .navigationTitle("Selecionar paragem")
        .onAppear {
            if let location = locationManager.location {
                suggestedStops = closestStops(to: location, stops: stopsManager.stops, maxResults: 10) // this is being done multiple times in the app, meybe consider globalizing it??
            } else {
                suggestedStops = Array(stopsManager.stops.prefix(10))
            }
        }
        .onChange(of: searchTerm) {
            print(searchTerm)
            let filtered = stopsManager.stops.filter {
                $0.id.localizedCaseInsensitiveContains(searchTerm) || $0.name.localizedCaseInsensitiveContains(searchTerm)
            }
            if filtered.count > 0 {
                suggestedStops = filtered
            } else {
                if let location = locationManager.location {
                    suggestedStops = closestStops(to: location, stops: stopsManager.stops, maxResults: 10)
                } else {
                    suggestedStops = Array(stopsManager.stops.prefix(10))

                }
            }
        }
    }
}
//
//#Preview {
//    SelectFavoriteStopView(selectedStopId: .constant("123"))
//}
