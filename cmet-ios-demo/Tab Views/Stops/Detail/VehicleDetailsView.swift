//
//  VehicleDetailsView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 09/05/2024.
//

import SwiftUI
import TipKit

struct VehicleOccupationTip: Tip {
    let occupation: Int?
    let total: Int
    
    var title: Text {
        Text("Ocupação do Veículo")
    }
    
    var message: Text {
        if let occupation = occupation {
            Text("Estão \(occupation) pessoas neste veículo de \(total) lugares.")
        } else {
            Text("Informação de ocupação indisponível para este veículo.")
        }
    }
    
//    var asset: Image {
//        Image(systemName: "")
//    }
    
    
}

struct VehicleDetailsView: View {
    @EnvironmentObject var vehiclesManager: VehiclesManager
    @EnvironmentObject var linesManager: LinesManager
    let vehicleId: String
    @State var vehicleStaticInfo: StaticVehicleInfo? = nil
    @State var vehiclePattern: Pattern? = nil
    
    @State private var vehicle: Vehicle? = nil
    
    var body: some View {
       var vehicleOccupationTip = VehicleOccupationTip(occupation: nil, total: (vehicleStaticInfo?.availableSeats ?? 0) + (vehicleStaticInfo?.availableStanding ?? 0))
        let vehicle = vehiclesManager.vehicles.first(where: {
            $0.id == vehicleId
        })
        if let vehicle = vehicle {
            let line = linesManager.lines.first {
                $0.id == vehicle.lineId
            }
            
            VStack {
                VStack(spacing: 10.0) {
                    Pill(text: vehicle.lineId, color: Color(hex: line!.color), textColor: Color(hex: line!.textColor), size: 60)
                    Text("para")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                    
                    if let pattern = vehiclePattern {
                        Text(pattern.headsign)
                            .font(.title2)
                            .bold()
                    }
                    
                    if let info = vehicleStaticInfo {
                        Text("\(info.make) \(info.model)")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                }
                
                Divider()
                HStack {
                    LicensePlate(licensePlate: "AA-00-AA")
                    //                VehicleIdentifier(vehicleId: vehicle.id, vehiclePlate: vehicleStaticInfo?.licensePlate)
                    Image(systemName: "circle")
                    Image(systemName: "figure.roll")
                        .foregroundStyle(.blue)
                    OccupationIndicator(occupied: nil, total: (vehicleStaticInfo?.availableSeats ?? 0) + (vehicleStaticInfo?.availableStanding ?? 0))
                        .popoverTip(vehicleOccupationTip)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                Divider()
                
                
                Text("\(vehicle.currentStatus) \(vehicle.stopId)")
                
                Text("\(vehicle.id)")
                
                Text("\(vehicle.lineId)")
                
                Text("\(vehicle.timestamp)")
                
                
                Spacer()
            }
            .onAppear {
                vehiclesManager.startFetching()
                Task {
                    vehiclePattern = try await CMAPI.shared.getPattern(vehicle.patternId)
                    print(vehiclePattern?.headsign)
                    vehicleStaticInfo = try await VehicleInfoAPI.shared.getVehicleInfo(id: vehicle.id)
                    print(vehicleStaticInfo)
                }
            }
            .onDisappear {
                vehiclesManager.stopFetching()
            }
        }
    }
}

struct OccupationIndicator: View {
    @State var viewSize: CGSize = .zero
//    @State private var isShowingPopover = false
    let occupied: Int?
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "person.3.sequence.fill")
                .foregroundStyle(getOccupancyColor())
            RoundedRectangle(cornerRadius: 25.0)
                .fill(getOccupancyColor().tertiary)
                .frame(height: 8)
                .overlay {
                    HStack {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(getOccupancyColor())
                            .frame(width: calculateBarWidth())
                        .padding(2)
                        if occupied != total && occupied ?? 0 < total {
                            Spacer()
                        }
                    }
                }
                .background {
                    GeometryReader {proxy in
                        Color.clear
                            .onAppear {
                                viewSize = proxy.size
                            }
                    }
                }
        }
//        .onTapGesture {
//            isShowingPopover.toggle()
//        }
//        .popover(isPresented: $isShowingPopover) {
//            Text("Your content here")
//                .font(.headline)
//                .padding()
//        }
    }
    
    private func calculateBarWidth() -> CGFloat {
        guard let occupied = occupied else { return 0 }
        if total == 0 {
            return 0
        } else if total <= occupied {
            return viewSize.width - 4 // subtract padding (both sides)
        } else {
            return viewSize.width * CGFloat(occupied) / CGFloat(total)
        }
    }
    
    private func getOccupancyColor() -> Color {
        guard let occupied = occupied else { return .gray }
        let occupancyRatio = (Double(occupied) / Double(total)) * 100
        print(occupancyRatio)
        
        switch occupancyRatio {
        case ..<50:
            return .green
        case 50..<80:
            return .yellow
        default:
            return .red
        }
    }
}

struct LicensePlate: View {
    let licensePlate: String
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.blue)
            Rectangle()
                .fill(.white)
                .overlay {
                    Text(licensePlate)
                }
        }
        .frame(height: 20)
    }
}

#Preview {
//    VehicleDetailsView(vehicle: Vehicle(
//        id: "42|2758",
//        timestamp: 1715243314,
//        scheduleRelationship: "SCHEDULED",
//        tripId: "4405_0_1|900|0900_58KXF",
//        patternId: "4405_0_1",
//        routeId: "4405_0",
//        lineId: "4405",
//        stopId: "160165",
//        currentStatus: "IN_TRANSIT_TO",
//        blockId: "Conecto_30072_18",
//        shiftId: "112140234560",
//        lat: 38.52212905883789,
//        lon: -8.884786605834961,
//        bearing: 121,
//        speed: 11.11111111111111
//    ))
    
    VehicleDetailsView(vehicleId: "42|2758")
}
