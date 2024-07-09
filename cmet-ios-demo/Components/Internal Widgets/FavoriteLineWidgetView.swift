//
//  FavoriteLineWidgetView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 14/03/2024.
//

import SwiftUI

// this one manages its own data and state for now but consider passing widget management to some external global utility
struct FavoriteLineWidgetView: View {
    @EnvironmentObject var vehiclesManager: VehiclesManager
    
    let patternId: String
    @State private var pattern: Pattern? = nil
    @State private var shape: CMShape? = nil
    
    @State private var filteredVehicles: [Vehicle] = []
    
    private var filteredVehiclesBinding: Binding<[Vehicle]> {
        Binding<[Vehicle]>(
            get: {
                vehiclesManager.vehicles.filter { $0.patternId == patternId }
            },
            set: { newValue in
            }
        )
    }
    
    private var patternStopsBinding: Binding<[Stop]> {
        Binding<[Stop]>(
            get: {
                pattern!.path.compactMap { $0.stop }
            },
            set: { newValue in
            }
        )
    }
    
//    let favoriteItem: FavoriteItem
    
    @State private var _______tempForUiDemoPurposes_isFavorited = true
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(alignment: .center) {
                    if let pattern = pattern {
                        Pill(text: pattern.lineId, color: Color(hex: pattern.color), textColor: Color(hex: pattern.textColor), size: 60)
                    } else {
                        Pill(text: "", color: .gray.opacity(0.4), textColor: .white, size: 60)
                            .blinking()
                    }
                    
                    if let pattern = pattern {
                        Text(pattern.headsign)
                            .font(.callout)
                            .bold()
                    } else {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.gray.opacity(0.4))
                            .frame(width: 120, height: 15)
                            .blinking()
                    }
                }
                Spacer()
                Button {
                    _______tempForUiDemoPurposes_isFavorited.toggle()
                } label: {
                    Image(systemName: _______tempForUiDemoPurposes_isFavorited ? "star.fill" : "star")
                        .font(.title2)
                    .foregroundStyle(.yellow)
                }
            }
            .padding(.vertical, 18.0)
            .padding(.horizontal, 15.0)
            
            Rectangle()
                .fill(.gray.opacity(0.1))
                .frame(height: 3.0)
            
            if let pattern = pattern, let shape = shape {
                ShapeAndVehiclesMapView(
                    stops: patternStopsBinding,
                    vehicles: filteredVehiclesBinding,
                    shape: $shape,
                    lineColor: Color(hex: pattern.color)
                )
                .frame(height: 200)
                .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(bottomLeading: 15.0, bottomTrailing: 15.0)))
            }
        }
        .background(RoundedRectangle(cornerRadius: 15.0).fill(.white)
            .shadow(color: .gray.opacity(0.3), radius: 20))
        .onAppear {
            Task {
                pattern = try await CMAPI.shared.getPattern(patternId)
                shape = try await CMAPI.shared.getShape(pattern!.shapeId)
                filteredVehicles = vehiclesManager.vehicles.filter { $0.patternId == patternId }
            }
        }
    }
}



//#Preview {
//    FavoriteLineWidgetView()
//        .shadow(color: .gray.opacity(0.3), radius: 20)
//        .padding()veh
//}
