//
//  FavoriteLineWidgetView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 14/03/2024.
//

import SwiftUI

// this one manages its own data and state for now but consider passing widget management to some external global utility
struct FavoriteLineWidgetView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var vehiclesManager: VehiclesManager
    
    let patternId: String
    @State private var pattern: Pattern? = nil
    @State private var shape: CMShape? = nil
    
    @State private var filteredVehicles: [Vehicle] = []
    
    let onHeaderTap: (_ lineId: String, _ patternId: String) -> Void
    
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
                Button {
                    if let pattern = pattern {
                        onHeaderTap(pattern.lineId, patternId)
                    }
                } label: {
                    HStack(alignment: .center) {
                        if let pattern = pattern {
                            Pill(text: pattern.lineId, color: Color(hex: pattern.color), textColor: Color(hex: pattern.textColor))
                        } else {
                            Pill(text: "", color: .gray.opacity(0.4), textColor: .white)
                                .blinking()
                        }
                        
                        Image(systemName: "arrow.right")
                            .bold()
                            .scaleEffect(0.7)
                            .frame(width: 15)
                        
                        if let pattern = pattern {
                            Text(pattern.headsign)
                                .font(.callout)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                        } else {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(.gray.opacity(0.4))
                                .frame(width: 120, height: 15)
                                .blinking()
                        }
                    }
                    Spacer()
                }
                .tint(.listPrimary)
//                Button {
//                    _______tempForUiDemoPurposes_isFavorited.toggle()
//                } label: {
//                    Image(systemName: _______tempForUiDemoPurposes_isFavorited ? "star.fill" : "star")
//                        .font(.title2)
//                    .foregroundStyle(.yellow)
//                }
            }
            .padding(.vertical, 18.0)
            .padding(.horizontal, 15.0)
            
            Rectangle()
                .fill(.gray.opacity(0.1))
                .frame(height: 3.0)
            
            Button {
                if let pattern = pattern {
                    onHeaderTap(pattern.lineId, patternId)
                }
            } label : {
                if let pattern = pattern, let shape = shape {
                    ShapeAndVehiclesMapView(
                        stops: patternStopsBinding,
                        vehicles: filteredVehiclesBinding,
                        shape: $shape,
                        isUserInteractionEnabled: false,
                        lineColor: Color(hex: pattern.color)
                    )
                    .frame(height: 250)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(bottomLeading: 15.0, bottomTrailing: 15.0)))
                    .overlay {
                        VStack {
                            Spacer()
                            HStack {
                                HStack {
                                    Circle()
                                        .fill(filteredVehiclesBinding.wrappedValue.count == 0 ? .gray.opacity(0.3) : .green.opacity(0.3))
                                        .frame(height: 20.0)
                                    Text("\(filteredVehiclesBinding.wrappedValue.count == 0 ? "Sem" : "")\(filteredVehiclesBinding.wrappedValue.count > 0 ? String(filteredVehiclesBinding.wrappedValue.count) : "") veículo\(filteredVehiclesBinding.wrappedValue.count == 1 ? "" : "s") em circulação")
                                        .foregroundStyle(filteredVehiclesBinding.wrappedValue.count == 0 ? .gray : .green)
                                        .bold()
                                        .font(.footnote)
                                        .padding(.horizontal, 5.0)
                                }
                                .padding(5.0)
                                .background {
                                    Capsule()
                                        .fill(.white.shadow(.drop(color: .black.opacity(0.2), radius: 10)))
                                }
                                .padding(10.0)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15.0)
                .fill(.cmSystemBackground100)
                .shadow(color: colorScheme == .light ? .black.opacity(0.05) : .clear, radius: 5)
        )
        .onAppear {
            Task {
                pattern = try await CMAPI.shared.getPattern(patternId)
                shape = try await CMAPI.shared.getShape(pattern!.shapeId)
//                filteredVehicles = vehiclesManager.vehicles.filter { $0.patternId == patternId }
            }
        }
    }
}



//#Preview {
//    FavoriteLineWidgetView()
//        .shadow(color: .gray.opacity(0.3), radius: 20)
//        .padding()veh
//}
