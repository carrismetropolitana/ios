//
//  VehicleDetailsView.swift
//  Carris Metropolitana
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

struct VehicleOccupationPopoverView: View {
    let occupation: Int?
    let total: Int
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.3.fill")
            VStack(alignment: .leading) {
                Text("Ocupação do Veículo")
                    .font(.headline)
                if let occupation = occupation {
                    Text("Estão \(occupation) pessoas neste veículo de \(total) lugares.")
                        .font(.subheadline)
                } else {
                    Text("Informação de ocupação indisponível para este veículo.")                        
                        .font(.subheadline)
                }
            }
        }
        .frame(height: 70)
    }
}

struct VehicleDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var vehiclesManager: VehiclesManager
    @EnvironmentObject var linesManager: LinesManager
    let vehicleId: String
    @State private var vehicleStaticInfo: StaticVehicleInfo? = nil
    @State private var vehiclePattern: Pattern? = nil
    @State private var vehicleStops: [Stop] = []
    @State private var vehicleShape: CMShape? = nil
    
    @State private var vehicle: VehicleV2? = nil
    
    @State private var isOccupationPopoverPresented = false
    
    var body: some View {
       var vehicleOccupationTip = VehicleOccupationTip(occupation: nil, total: (vehicleStaticInfo?.availableSeats ?? 0) + (vehicleStaticInfo?.availableStanding ?? 0))
        let vehicle = vehiclesManager.vehicles.first(where: {
            $0.id == vehicleId
        })
        if let vehicle = vehicle {
            let line = linesManager.lines.first {
                $0.id == vehicle.lineId
            }
            
            ScrollView {
                VStack(spacing: 10.0) {
                    // will always be true but let's avoid forced unwrappings on remote values
                    if let vehicleLineId = vehicle.lineId {
                        Pill(text: vehicleLineId, color: Color(hex: line!.color), textColor: Color(hex: line!.textColor))
                    }
                    Text("para", comment: "Texto entre o número da linha e o headsign de um autocarro na tracking view.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                    
                    if let pattern = vehiclePattern {
                        Text(pattern.headsign)
                            .font(.title2)
                            .bold()
                    }
                    
                    if let info = vehicleStaticInfo {
                        Text(verbatim: "\(info.make) \(info.model)")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                }
                
                Divider()
                HStack {
                    VehicleIdentifier(vehicleId: vehicle.id, vehiclePlate: vehicle.licensePlate)
                    Pulse(size: 20.0, accent: .green)
                    Image(systemName: "figure.roll")
                        .foregroundStyle((vehicle.wheelchairAccessible ?? false) ? .blue : .secondary)
                    OccupationIndicator(occupied: vehicle.occupancyEstimated, total: (vehicle.capacityTotal ?? 0))
                        .onTapGesture {
                            isOccupationPopoverPresented.toggle()
                        }
                        .popover(isPresented: $isOccupationPopoverPresented){
                            VehicleOccupationPopoverView(occupation: nil, total: (vehicle.capacityTotal ?? 0))
                                .padding(10)
                                .presentationCompactAdaptation(.popover)
                        }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                Divider()
                
                if let pattern = vehiclePattern, let _ = vehicleShape {
                    ShapeAndVehiclesMapView(stops: vehicleStops, vehicles: [vehicle], shape: vehicleShape, lineColor: Color(hex: pattern.color))
                        .frame(height: 200)
                }
                
                HStack {
                    Text("Percurso")
                        .bold()
                        .font(.title2)
                        .padding()
                    Spacer()
                }
                
                if (vehicleStops.count > 0) {
                    if let vehicleCurrentStatus = vehicle.currentStatus {
                        OtherTestPreview(stops: vehicleStops, nextStopIndex: vehicleStops.firstIndex(where: {$0.id == vehicle.stopId})!, vehicleStatus: getVehicleStatus(for: vehicleCurrentStatus))
                    }
                }
            
//                UserFeedbackForm(
//                    title: "Estas informações estão corretas?",
//                    description: "Ajude-nos a melhorar os transportes para todos.",
//                    questions: [
//                        Question(text: "Percursos e Paragens", type: .yesOrNo, onAction: {value in print("User responded with value \(value) to question Percursos e Paragens")}),
//                        Question(text: "Estimativas de Chegada", type: .yesOrNo, onAction: {value in print("User responded with value \(value) to question Estimativas de Chegada")}),
//                        Question(text: "Informações no Veículo", type: .yesOrNo, onAction: {value in print("User responded with value \(value) to question Informações no Veículo")})
//                    ]
//                )
            }
            .navigationTitle("Autocarro")
            .contentMargins(.top, 20.0, for: .scrollContent)
            .onAppear {
                vehiclesManager.startFetching()
                Task {
                    if let vehiclePatternId = vehicle.patternId {
                        vehiclePattern = try await CMAPI.shared.getPattern(vehiclePatternId)
                        if let pattern = vehiclePattern {
                            vehicleStops = pattern.path.compactMap {$0.stop}
                            vehicleShape = try await CMAPI.shared.getShape(pattern.shapeId)
                        }
                        print(vehiclePattern?.headsign)
                        vehicleStaticInfo = try await VehicleInfoAPI.shared.getVehicleInfo(id: vehicle.id)
                        print(vehicleStaticInfo)
                    }
                }
            }
            .onDisappear {
                // vehiclesManager.stopFetching()
            }
        }
        else {
            UnavailableBus()
        }
    }
    
    func getVehicleStatus(for statusString: String) -> VehicleStatus? {
        switch statusString {
        case "IN_TRANSIT_TO":
            return .inTransitTo
        case "INCOMING_AT":
            return .incomingAt
        case "STOPPED_AT":
            return .stoppedAt
        default:
            return nil
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

struct UnavailableBus: View {
    var body: some View {
        VStack {
            Image(.lostBus)
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.bottom, 30.0)
            Text("Veículo indispoível".uppercased())
                .font(.title3)
                .foregroundStyle(.secondary)
                .fontWeight(.black)
            Text("O veículo terminou a viagem ou está incontactável.\nPor favor volte a tentar mais tarde.")
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.horizontal, 5.0)
                .multilineTextAlignment(.center)
        }
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
    
    //    VehicleDetailsView(vehicleId: "42|2758")
    //    OccupationIndicator(occupied: 120, total: 50)
    //        .frame(width: 200)
//    VStack {
//        Rectangle()
//            .frame(width: 100, height: 100)
//            .popover(isPresented: .constant(true)) {
//                VehicleOccupationPopoverView(occupation: 100, total: 250)
//                    .padding(10)
//                    .presentationCompactAdaptation(.popover)
//        }
//        Spacer()
//    }
    VStack {
        Image(.lostBus)
            .resizable()
            .frame(width: 100, height: 100)
            .padding(.bottom, 30.0)
        Text("Veículo indispoível".uppercased())
            .font(.title3)
            .foregroundStyle(.secondary)
            .fontWeight(.black)
        Text("O veículo terminou a viagem ou está incontactável.\nPor favor volte a tentar mais tarde.")
            .foregroundStyle(.secondary)
            .font(.callout)
            .padding(.horizontal, 5.0)
            .multilineTextAlignment(.center)
    }
}
