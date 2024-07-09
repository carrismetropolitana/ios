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
    
    var body: some View {
        VStack {
            MapLibreMapView(stops: stopsManager.stops, selectedStopId: .constant(nil))
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
        }
        .navigationTitle("Selecionar paragem")
        .onAppear {
            if let location = locationManager.location {
                suggestedStops = closestStops(to: location, stops: stopsManager.stops, maxResults: 10)
            } else {
                suggestedStops = Array(stopsManager.stops.prefix(10))
            }
        }
    }
}
//
//#Preview {
//    SelectFavoriteStopView(selectedStopId: .constant("123"))
//}
