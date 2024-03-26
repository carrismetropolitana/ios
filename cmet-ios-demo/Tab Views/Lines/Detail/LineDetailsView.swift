//
//  RouteDetailsView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 14/03/2024.
//

import SwiftUI
import MapKit


struct LineDetailsView: View {
    @EnvironmentObject var alertsManager: AlertsManager
    @EnvironmentObject var vehiclesManager: VehiclesManager
    
    @State private var timer: Timer?
    let line: Line
    
    @State private var isAlertsSheetPresented = false
    
    @State private var selectedPattern: Pattern?
    @State private var selectedStop: Stop?
    @State private var routes: [Route] = []
    @State private var patterns: [Pattern] = []
    @State private var currentPatternEtas: [EtaEntryWithStopId] = []
    @State private var unfilteredVehicles: [Vehicle] = []
    @State private var vehicles: [Vehicle] = []
    @State private var shape: CMShape?
    
    @State private var mapHeight: CGFloat = 200
    @State private var hasMapHeightChangedOnce = false
    
    @State private var isMapExpanded = false
    
    @State private var _______tempForUiDemoPurposes_isFavorited = false
    
    var body: some View {
        let lineAlerts = alertsManager.alerts.filter {
            var isLineAffected = false
            for informedEntity in $0.alert.informedEntity {
                if let routeId = informedEntity.routeId {
                    if (line.routes.contains(routeId)) {
                        isLineAffected = true
                    }
                }
                
                // show only line alerts or stops in line alerts too??
//                if let stopId = informedEntity.stopId {
//                    if (line.patterns.)
//                }
            }
            
            return isLineAffected
        }
        
        ScrollView {
            VStack(alignment: .leading) {
                if let selectedPattern = selectedPattern {
                    VStack(alignment: .leading) {
                        HStack {
                            Pill(text: line.shortName, color: Color(hex: line.color), textColor: Color(hex: line.textColor), size: 60)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                            if (isMapExpanded) {
                                Text(line.longName)
                                    .bold()
                                    .lineLimit(1)
                            }
                        }
                        if (!isMapExpanded) {
                            Text(line.longName)
                                .bold()
                                .padding(.horizontal)
                            HStack(spacing: 10.0) {
                                SquaredButton(
                                    action: {
                                        // FavoritesService.addLineToFavorites(lineId: line.id)
                                        _______tempForUiDemoPurposes_isFavorited.toggle()
                                    },
                                    systemIcon: _______tempForUiDemoPurposes_isFavorited ? "star.fill" : "star",
                                    imageResourceIcon: nil, // FavoritesService.isFavorite(lineId: line.id) ? "star.fill" : "star"
                                    iconColor: .yellow,
                                    badgeValue: 0
                                )
                                SquaredButton(
                                    action: {
                                        isAlertsSheetPresented.toggle()
                                    },
                                    systemIcon: "exclamationmark.triangle",
                                    //                                    systemIcon: nil,
                                    //                                    imageResourceIcon: .exclamationMarkTriangleFilled,
                                    imageResourceIcon: nil,
                                    iconColor: .primary,
                                    badgeValue: lineAlerts.count
                                )
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10.0)
                        }
                        
                        
                        Divider()
                        
                        
                        Group {
                            Text("Selecionar destino")
                            Picker("Selecionar destino", selection: $selectedPattern) {
                                ForEach(patterns, id: \.id) { pattern in // why the fuck does it need me to specify id if Pattern conforms to identifiable? is it because it is an optional? (Pattern?)
                                    //                            Text("\(pattern.headsign) (\(routes.first(where: {$0.id == pattern.routeId})?.longName ?? ""))")
                                    //                                .tag(pattern.id)
                                    Text(pattern.headsign)
                                        .tag(pattern as Pattern?) // FUCK MEEEEE @see https://stackoverflow.com/questions/59348093/picker-for-optional-data-type-in-swiftui/59348094#59348094
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .background(RoundedRectangle(cornerRadius: 10.0).fill(.gray.quinary))
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)

                    if let _ = shape {
                        ShapeAndVehiclesMapView(stops: .constant(selectedPattern.path.compactMap {$0.stop}), vehicles: $vehicles, shape: $shape, lineColor: Color(hex: line.color))
                            .frame(height: isMapExpanded ? 600 : 300)
                            .overlay {
                                VStack {
                                    Spacer()
                                    HStack {
                                        HStack {
                                            Circle()
                                                .fill(.green.gradient.opacity(0.3))
                                                .frame(height: 20.0)
                                            Text("\(vehicles.count) veículo\(vehicles.count == 1 ? "" : "s") em circulação")
                                                .foregroundStyle(.green)
                                                .bold()
                                                .font(.footnote)
                                                .padding(.horizontal, 5.0)
                                        }
                                        .padding(5.0)
                                        .background {
                                            Capsule()
                                                .fill(.white.shadow(.drop(color: .black.opacity(0.2), radius: 10)))
                                        }
                                        .padding()
                                        Spacer()
                                        Button {
                                            withAnimation {
                                                isMapExpanded.toggle()
                                            }
                                        } label: {
                                            Image(systemName: isMapExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                                .padding(10.0)
                                                .background {
                                                    Circle()
                                                        .fill(.thickMaterial)
                                                }
                                                .padding()
                                        }
                                    }
                                }
                            }
                    }
                
                
                
                    PatternLegs(pattern: selectedPattern, selectedStop: $selectedStop, etasWithStopIds: currentPatternEtas)
                        .padding(.vertical)
                    
                } else {
                    LoadingBar(size: 10)
                }
            }
        }
        .navigationTitle("Linha")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://beta.carrismetropolitana.pt/lines/\(line.id)")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $isAlertsSheetPresented) {
            // try await AlertsService.fetchNew()
            AlertsSheetView(isSelfPresented: $isAlertsSheetPresented, alerts: lineAlerts, source: .line) // AlertsService.alerts.find(where: { $0.alert.informedEntities blableblibloblu })
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            if patterns.count == 0 {
                Task {
                    for routeId in line.routes {
                        let route: Route = try await CMAPI.shared.getRoute(routeId)
                        routes.append(route)
                        
                        for patternId in route.patterns {
                            let pattern: Pattern = try await CMAPI.shared.getPattern(patternId)
                            patterns.append(pattern)
                        }
                    }
                    
                    selectedPattern = patterns.first
                    
                    if selectedPattern != nil {
                        shape = (try await CMAPI.shared.getShape(selectedPattern!.shapeId))
                    }
                }
            }
            
            vehiclesManager.startFetching()
            
            fetchVehiclesAndEtas()
            
            startFetchingTimer()
        }
        .onDisappear {
            print("LineDetailsView onDisappear called")
            stopFetchingTimer()
            vehiclesManager.stopFetching()
        }
        .onChange(of: selectedPattern) { // manual vehicle clear and refetch on pattern change
            vehicles = []
            Task {
                if let pattern = selectedPattern {
                    vehicles = vehiclesManager.vehicles.filter {$0.patternId == pattern.id}
                    
                    print("Refiltered vehicles on pattern change. Got \(vehicles.count) vehicles for selected pattern.")
                    
                    shape = (try await CMAPI.shared.getShape(selectedPattern!.shapeId))
                    
                    print("Changed shape on pattern change")
                }
            }
        }
//        .onChange(of: selectedPattern) {
//            print("Selected pattern changed!")
//            Task {
//                if selectedPattern != nil {
//                    vehicles = (try await api.getVehicles()).filter {$0.patternId == selectedPattern!.id}
//                    
//                    var etas: [RealtimeETA] = []
//                    for pathEntry in selectedPattern!.path { // do all these concurrently
//                        etas = try await api.getETAs(pathEntry.stop.id)
//                        currentPatternEtas.append(.init(stopId: pathEntry.stop.id, etas: etas))
//                    }
//                }
//            }
//        }
        
//        .onChange(of: selectedPattern) {
//            print("Selected pattern changed!")
//            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
//                Task {
//                    if let pattern = selectedPattern {
//                        vehicles = (try await api.getVehicles()).filter {$0.patternId == pattern.id}
//                        
//                        try await withThrowingTaskGroup(of: (stopId: String, etas: [RealtimeETA]).self) { group in
//                            for pathEntry in pattern.path {
//                                group.addTask {
//                                    let etas = try await api.getETAs(pathEntry.stop.id)
//                                    return (stopId: pathEntry.stop.id, etas: etas)
//                                }
//                            }
//                            
//                            var etasToSet: [EtaEntryWithStopId] = []
//                            
//                            for try await result in group {
//                                etasToSet.append(.init(stopId: result.stopId, etas: result.etas))
//                            }
//                            
//                            currentPatternEtas = etasToSet
//                        }
//                        
//                        print("Got \(vehicles.count) vehicles and \(currentPatternEtas.count) ETAS for pattern \(selectedPattern!.id)")
//                    }
//                }
//            }
//        }
    }

    private func fetchVehiclesAndEtas() {
        Task {
            if let pattern = selectedPattern {
//                unfilteredVehicles = try await CMAPI.shared.getVehicles()
                vehicles = vehiclesManager.vehicles.filter {$0.patternId == pattern.id}
                
                
                try await withThrowingTaskGroup(of: (stopId: String, etas: [RealtimeETA]).self) { group in
                    for pathEntry in pattern.path {
                        group.addTask {
                            let etas = try await CMAPI.shared.getETAs(pathEntry.stop.id)
                            return (stopId: pathEntry.stop.id, etas: etas)
                        }
                    }
                    
                    var etasToSet: [EtaEntryWithStopId] = []
                    
                    for try await result in group {
                        etasToSet.append(.init(stopId: result.stopId, etas: result.etas))
                    }
                    
                    currentPatternEtas = etasToSet
                }
                
                print("Got \(vehicles.count) vehicles and \(currentPatternEtas.count) ETAS for pattern \(selectedPattern!.id)")
            }
        }
    }
    
    private func startFetchingTimer() {
        // Create a timer to trigger fetching every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            fetchVehiclesAndEtas()
        }
    }
    
    private func stopFetchingTimer() {
        // Invalidate the timer to stop fetching
        timer?.invalidate()
        timer = nil
    }
}

private struct EtaEntryWithStopId {
    let stopId: String
    let etas: [RealtimeETA]
}

struct PatternLegs: View {
    let pattern: Pattern
    @State private var isSheetPresented = false
    @State private var selectedSchedulesDate = Date()
    @Binding var selectedStop: Stop? // would be ok to just keep state inside this component but maybe in the future we may need to access from parent so lets keep it this way
    @State private var selectedStopIndex: Int?
    fileprivate let etasWithStopIds: [EtaEntryWithStopId]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0)  {
            ForEach(pattern.path.indices, id: \.hashValue) { pathStepIdx in
                let isFirst = pathStepIdx == 0
                let isLast = pathStepIdx == pattern.path.count - 1
                
                let pathStep = pattern.path[pathStepIdx]
                let isSelected = selectedStop?.id == pathStep.stop.id // TODO: deprecate this as somethimes stops repeat in a pattern
                let isSelectedByIndex = selectedStopIndex == pathStepIdx
                
                let etas = etasWithStopIds.first(where: {$0.stopId == pathStep.stop.id})?.etas
                let etasForSelectedPattern = etas?.filter({$0.patternId == pattern.id})
                
                let nextEtas = etasForSelectedPattern != nil ? filterAndSortCurrentAndFutureETAs(etasForSelectedPattern!) : [] // TODO: deoptionalize lol
                
                HStack {
                    HStack {
                        ZStack {
                            VStack {
                                Text("—")
                                    .bold()
                                    .offset(x: 10, y: -2)
                                    .padding(.top, isSelectedByIndex ? 10 : 0)
                                Spacer()
                            }
                            VStack {
                                UnevenRoundedRectangle(cornerRadii: .init(topLeading: isFirst ? 10 : 0, bottomLeading: isLast ? 10 : 0, bottomTrailing: isLast ? 10 : 0, topTrailing: isFirst ? 10 : 0))
                                    .fill(Color(hex: pattern.color))
                                    .frame(width: 15, height: isLast && isSelectedByIndex ? 30 : isLast ? 20 : nil)
                                    .overlay {
                                        VStack {
                                            if isLast {Spacer()}
                                            Circle()
                                                .fill(.white)
                                                .padding(isLast ? 3.5 : 5)
                                                .padding(.top, isLast ? 0 : 2)
                                                .offset(y : isLast ? -4 : 0)
                                                .padding(.top, isSelectedByIndex ? 10 : 0)
                                            if !isLast {Spacer()}
                                        }
                                    }
                                if isLast {Spacer()}
                            }
                            .padding(.leading, 5)
                        }
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text(pathStep.stop.name)
                                    .font(isSelectedByIndex ? .headline : .subheadline)
                                    .fontWeight(isSelectedByIndex ? .bold : .semibold)
                                Text(pathStep.stop.locality == pathStep.stop.municipalityName || pathStep.stop.locality == nil ? pathStep.stop.municipalityName : "\(pathStep.stop.locality!), \(pathStep.stop.municipalityName)")
                                    .foregroundStyle(.secondary)
                                if isSelectedByIndex {
                                    if pathStep.stop.facilities.count > 0 {
                                        HStack {
                                            ForEach(pathStep.stop.facilities, id: \.self) { facility in
                                                let imageResource = getImageResourceForFacility(facility)
                                                if let imageResource = imageResource {
                                                    Image(imageResource)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30.0)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 5)
                                    } else {
                                        Spacer()
                                            .frame(height: 30)
                                    }
                                }
                                
                                HStack(spacing: 20.0) {
                                    if let nextEtaEstimatedArrival = nextEtas.first?.estimatedArrivalUnix {
                                        HStack {
                                            let minutesToArrival = getRoundedMinuteDifferenceFromNow(nextEtaEstimatedArrival)
                                            
                                            
                                            PulseLabel(accent: .green, label: Text(minutesToArrival <= 1 ? "A chegar" : "\(String(minutesToArrival)) minutos"))
                                        }
                                    }
                                    if isSelectedByIndex {
                                        if nextEtas.count > 0 {
                                            NextEtasView(nextEtas: Array(nextEtas.prefix(3)))
                                        } else {
                                            Text("Sem próximas passagens.")
                                                .font(.subheadline)
                                                .italic()
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                
                                
                                
                                
                                if isSelectedByIndex {
                                    HStack {
                                        Button {
                                            isSheetPresented.toggle()
                                        } label: {
                                            HStack {
                                                Image(systemName: "clock.badge")
                                                Text("Horários")
                                            }
                                        }
                                        .buttonStyle(StopOptionsButtonStyle())
                                        
                                        Button {
                                            
                                        } label: {
                                            HStack {
                                                Image(systemName: "mappin.and.ellipse")
                                                Text("Sobre a Paragem")
                                            }
                                        }
                                        .buttonStyle(StopOptionsButtonStyle())
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        .padding(.leading, 10)
                        .padding(.vertical, isSelectedByIndex ? 10 : 0)
                        
                        Spacer() // extend to the edge of the screen
                    }
                    .padding(.horizontal)
                }
                .background(.windowBackground)
                .clipped()
                .shadow(color: .black.opacity(0.1), radius: isSelectedByIndex ? 20 : 0)
                .zIndex(isSelected ? 1 : 0)
                .onTapGesture {
                    selectedStop = pathStep.stop
                    selectedStopIndex = pathStepIdx
                    
                }
            }
        }
        .onChange(of: pattern) {
            selectedStop = nil
            selectedStopIndex = nil
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                HStack {
                    Text("Horários")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                .padding()
                
                HStack {
                    DatePicker("Selecione uma data",
                       selection: $selectedSchedulesDate,
                       displayedComponents: [.date]
                    )
                    .labelsHidden()
                    Spacer()
                }
                .padding(.horizontal)
                
                if selectedStop != nil {
                    let scheduleColumns = schedulizeTripsForDateAndStop(stopId: selectedStop!.id, trips: pattern.trips, date: selectedSchedulesDate)
                    if scheduleColumns.count > 0 {
                        ScheduleView(scheduleColumns: scheduleColumns)
                    } else {
                        ContentUnavailableView("Sem horários para a data selecionada", systemImage: "calendar.badge.exclamationmark", description: Text("Experimente selecionar uma data mais próxima da atual.")) // TODO: need to make this manually for older OSes (only available on iOS 17)
                    }
                }
                Spacer()
            }
            .presentationDetents([.fraction(0.45)])
        }
    }
}

struct NextEtasView: View {
    let nextEtas: [RealtimeETA]
    var body: some View {
        Image(systemName: "clock")
        ForEach(nextEtas, id: \.self) { eta in
            if let estimatedArrival = eta.estimatedArrival {
                let timeComponents = estimatedArrival.components(separatedBy: ":")
                Text("\(timeComponents[0]):\(timeComponents[1])")
                    .foregroundStyle(.green)
            }
            
            if let scheduledArrival = eta.scheduledArrival {
                let timeComponents = scheduledArrival.components(separatedBy: ":")
                Text("\(timeComponents[0]):\(timeComponents[1])")
            }
            
        }
    }
}

struct StopOptionsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundColor(.secondary)
            .background(.quinary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Optional: Add a scale effect when pressed
            .animation(.easeInOut(duration: 0.1)) // Optional: Add animation for a smooth transition
    }
}

// logic for this in https://github.com/carrismetropolitana/website/blob/4f9f9495428d5aa9a81f00611ae3bf4f5fddbe14/nextjs/components/FrontendStopsTimetable/FrontendStopsTimetable.js#L39
func filterAndSortCurrentAndFutureETAs(_ etas: [RealtimeETA]) -> [RealtimeETA] {
    let currentAndFutureFiltering = etas.filter({
        let tripHasObservedArrival = $0.observedArrivalUnix != nil
        let tripScheduledArrivalIsInThePast = $0.scheduledArrivalUnix ?? 0 <= Int(Date().timeIntervalSince1970)
        let tripHasEstimatedArrival = $0.estimatedArrivalUnix != nil
        let tripEstimatedArrivalIsInThePast = $0.estimatedArrivalUnix ?? 0 <= Int(Date().timeIntervalSince1970)
        
        return !tripHasObservedArrival && (!tripScheduledArrivalIsInThePast || tripHasEstimatedArrival) && !tripEstimatedArrivalIsInThePast
    })
    
    print("Filtered \(currentAndFutureFiltering.count) ETAs as currentAndFuture.")
    
    let sorted = currentAndFutureFiltering.sorted { (a, b) -> Bool in
        if let estimatedArrivalA = a.estimatedArrivalUnix, let estimatedArrivalB = b.estimatedArrivalUnix {
            // Both have estimated_arrival, compare them
            return estimatedArrivalA < estimatedArrivalB
        } else if a.estimatedArrivalUnix != nil {
            // Only `a` has estimated_arrival, so it comes before `b`
            return true
        } else if b.estimatedArrivalUnix != nil {
            // Only `b` has estimated_arrival, so it comes before `a`
            return false
        } else {
            // Both have only scheduled_arrival, compare them
            return a.scheduledArrivalUnix! < b.scheduledArrivalUnix!
        }
//        $0.scheduledArrivalUnix! < $1.scheduledArrivalUnix!
    }
    
    return sorted
}

func getRoundedMinuteDifferenceFromNow(_ refTimestamp: Int) -> Int {
    let now = Int(Date().timeIntervalSince1970)
    let differenceInSeconds = now - refTimestamp
    let differenceInMinutes = differenceInSeconds / 60
    return Int(differenceInMinutes.magnitude)
}

func getImageResourceForFacility(_ facility: Facility) -> ImageResource? {
    switch facility {
    case .boat:
        return .cmFacilityBoat
    case .lightRail:
        return .cmFacilityLightRail
    case .school:
        return .cmFacilitySchool
    case .shopping:
        return .cmFacilityShopping
    case .subway:
        return .cmFacilitySubway
    case .train:
        return .cmFacilityTrain
    case .transitOffice:
        return .cmFacilityTransitOffice
    default:
        return nil
    }
}

func schedulizeTripsForDateAndStop(stopId: String, trips: [Trip], date: Date) -> [ScheduleColumn] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"

    let formattedDate = dateFormatter.string(from: date)
    
    
    var schedules: [ScheduleColumn] = []
    
    for trip in trips {
        if trip.dates.contains(formattedDate) {
            for tripStep in trip.schedule {
                if tripStep.stopId == stopId {
                    let timeComponents = tripStep.arrivalTime.components(separatedBy: ":")
                    if let scheduleIdx = schedules.firstIndex(where: {$0.hour == Int(timeComponents[0])}) {
                        schedules[scheduleIdx].minutes.append(Int(timeComponents[1])!)
                    } else {
                        schedules.append(.init(hour: Int(timeComponents[0])!, minutes: [
                            Int(timeComponents[1])!
                        ]))
                    }
//                    rawSchedules.append(tripStep.arrivalTime)
                }
            }
        }
    }
    
    return schedules
}


//#Preview {
//    
//    let route = RouteAPI(
//        id: "3536_0",
//        lineId: "3536",
//        shortName: "3536",
//        longName: "Cacilhas (Terminal) - Sesimbra (Terminal)",
//        color: "#C61D23",
//        textColor: "#FFFFFF",
//        patterns: [
//            "3536_0_1",
//            "3536_0_2"
//        ],
//        municipalities: [
//            "1503",
//            "1510",
//            "1511"
//        ],
//        localities: [
//            "Cacilhas",
//            "Cova da Piedade",
//            "Laranjeiro",
//            "Corroios",
//            "Sta. Marta do Pinhal",
//            "Sta. Marta de Corroios",
//            "Muxito",
//            "Seixal",
//            "Cruz de Pau",
//            "Foros de Amora",
//            "Paivas",
//            "Marco Severino",
//            "Fogueteiro",
//            "Fernão Ferro",
//            "Sesimbra",
//            "Carrasqueira",
//            "Quintinhas",
//            "Cotovia",
//            "Santana"
//        ],
//        facilities: []
//    )
//    
//    let pattern = Pattern(
//        id: "3536_0_1",
//        lineId: "3536",
//        routeId: "3536_0",
//        shortName: "3536",
//        direction: 0,
//        headsign: "Sesimbra (Terminal)",
//        color: "#C61D23",
//        textColor: "#FFFFFF",
//        validOn: [
//            "20230911",
//            "20230912",
//            "20230913",
//            "20230914",
//            "20230915",
//            "20230918",
//            "20230919",
//            "20230920",
//            "20230921",
//            "20230922",
//            "20230925",
//            "20230926",
//            "20230927",
//            "20230928",
//            "20230929",
//            "20231002",
//            "20231003",
//            "20231004",
//            "20231006",
//            "20231009",
//            "20231010",
//            "20231011",
//            "20231012",
//            "20231013",
//            "20231016",
//            "20231017",
//            "20231018",
//            "20231019",
//            "20231020",
//            "20231023",
//            "20231024",
//            "20231025",
//            "20231026",
//            "20231027",
//            "20231030",
//            "20231031",
//            "20231102",
//            "20231103",
//            "20231106",
//            "20231107",
//            "20231108",
//            "20231109",
//            "20231110",
//            "20231113",
//            "20231114",
//            "20231115",
//            "20231116",
//            "20231117",
//            "20231120",
//            "20231121",
//            "20231122",
//            "20231123",
//            "20231124",
//            "20231127",
//            "20231128",
//            "20231129",
//            "20231130",
//            "20231204",
//            "20231205",
//            "20231206",
//            "20231207",
//            "20231211",
//            "20231212",
//            "20231213",
//            "20231214",
//            "20231215",
//            "20231218",
//            "20231219",
//            "20231220",
//            "20231221",
//            "20231222",
//            "20240103",
//            "20240104",
//            "20240105",
//            "20240108",
//            "20240109",
//            "20240110",
//            "20240111",
//            "20240112",
//            "20240115",
//            "20240116",
//            "20240117",
//            "20240118",
//            "20240119",
//            "20240122",
//            "20240123",
//            "20240124",
//            "20240125",
//            "20240126",
//            "20240129",
//            "20240130",
//            "20240131",
//            "20240201",
//            "20240202",
//            "20240205",
//            "20240206",
//            "20240207",
//            "20240208",
//            "20240209",
//            "20240215",
//            "20240216",
//            "20240219",
//            "20240220",
//            "20240221",
//            "20240222",
//            "20240223",
//            "20240226",
//            "20240227",
//            "20240228",
//            "20240229",
//            "20240301",
//            "20240304",
//            "20240305",
//            "20240306",
//            "20240307",
//            "20240308",
//            "20240311",
//            "20240312",
//            "20240313",
//            "20240314",
//            "20240315",
//            "20240318",
//            "20240319",
//            "20240320",
//            "20240321",
//            "20240322",
//            "20240401",
//            "20240402",
//            "20240403",
//            "20240404",
//            "20240405",
//            "20240408",
//            "20240409",
//            "20240410",
//            "20240411",
//            "20240412",
//            "20240415",
//            "20240416",
//            "20240417",
//            "20240418",
//            "20240419",
//            "20240422",
//            "20240423",
//            "20240424",
//            "20240426",
//            "20240429",
//            "20240430",
//            "20240502",
//            "20240503",
//            "20240506",
//            "20240507",
//            "20240508",
//            "20240509",
//            "20240510",
//            "20240513",
//            "20240514",
//            "20240515",
//            "20240516",
//            "20240517",
//            "20240520",
//            "20240521",
//            "20240522",
//            "20240523",
//            "20240524",
//            "20240527",
//            "20240528",
//            "20240529",
//            "20240531",
//            "20240603",
//            "20240604",
//            "20240605",
//            "20240606",
//            "20240607",
//            "20240611",
//            "20240612",
//            "20240613",
//            "20240614",
//            "20240617",
//            "20240618",
//            "20240619",
//            "20240620",
//            "20240621",
//            "20240624",
//            "20240625",
//            "20240626",
//            "20240627",
//            "20240628",
//            "20230901",
//            "20230904",
//            "20230905",
//            "20230906",
//            "20230907",
//            "20230908",
//            "20231226",
//            "20231227",
//            "20231228",
//            "20231229",
//            "20240102",
//            "20240212",
//            "20240214",
//            "20240325",
//            "20240326",
//            "20240327",
//            "20240328",
//            "20230703",
//            "20230704",
//            "20230705",
//            "20230706",
//            "20230707",
//            "20230710",
//            "20230711",
//            "20230712",
//            "20230713",
//            "20230714",
//            "20230717",
//            "20230718",
//            "20230719",
//            "20230720",
//            "20230721",
//            "20230724",
//            "20230725",
//            "20230726",
//            "20230727",
//            "20230728",
//            "20230731",
//            "20230801",
//            "20230802",
//            "20230803",
//            "20230804",
//            "20230807",
//            "20230808",
//            "20230809",
//            "20230810",
//            "20230811",
//            "20230814",
//            "20230816",
//            "20230817",
//            "20230818",
//            "20230821",
//            "20230822",
//            "20230823",
//            "20230824",
//            "20230825",
//            "20230828",
//            "20230829",
//            "20230830",
//            "20230831",
//            "20230916",
//            "20230923",
//            "20230930",
//            "20231007",
//            "20231014",
//            "20231021",
//            "20231028",
//            "20231104",
//            "20231111",
//            "20231118",
//            "20231125",
//            "20231202",
//            "20231209",
//            "20231216",
//            "20240106",
//            "20240113",
//            "20240120",
//            "20240127",
//            "20240203",
//            "20240210",
//            "20240217",
//            "20240224",
//            "20240302",
//            "20240309",
//            "20240316",
//            "20240406",
//            "20240413",
//            "20240420",
//            "20240427",
//            "20240504",
//            "20240511",
//            "20240518",
//            "20240525",
//            "20240601",
//            "20240608",
//            "20240615",
//            "20240622",
//            "20240629",
//            "20230902",
//            "20230909",
//            "20231223",
//            "20231230",
//            "20240213",
//            "20240323",
//            "20240330",
//            "20230701",
//            "20230708",
//            "20230715",
//            "20230722",
//            "20230729",
//            "20230805",
//            "20230812",
//            "20230819",
//            "20230826",
//            "20230917",
//            "20230924",
//            "20231001",
//            "20231005",
//            "20231008",
//            "20231015",
//            "20231022",
//            "20231029",
//            "20231101",
//            "20231105",
//            "20231112",
//            "20231119",
//            "20231126",
//            "20231201",
//            "20231203",
//            "20231208",
//            "20231210",
//            "20231217",
//            "20240107",
//            "20240114",
//            "20240121",
//            "20240128",
//            "20240204",
//            "20240211",
//            "20240218",
//            "20240225",
//            "20240303",
//            "20240310",
//            "20240317",
//            "20240407",
//            "20240414",
//            "20240421",
//            "20240425",
//            "20240428",
//            "20240501",
//            "20240505",
//            "20240512",
//            "20240519",
//            "20240526",
//            "20240530",
//            "20240602",
//            "20240609",
//            "20240610",
//            "20240616",
//            "20240623",
//            "20240630",
//            "20230903",
//            "20230910",
//            "20240324",
//            "20240329",
//            "20240331",
//            "20230702",
//            "20230709",
//            "20230716",
//            "20230723",
//            "20230730",
//            "20230806",
//            "20230813",
//            "20230815",
//            "20230820",
//            "20230827"
//        ],
//        municipalities: [
//            "1503",
//            "1510",
//            "1511"
//        ],
//        localities: [
//            "Cacilhas",
//            "Cova da Piedade",
//            "Laranjeiro",
//            "Corroios",
//            "Sta. Marta do Pinhal",
//            "Sta. Marta de Corroios",
//            "Muxito",
//            "Seixal",
//            "Cruz de Pau",
//            "Foros de Amora",
//            "Paivas",
//            "Marco Severino",
//            "Fogueteiro",
//            "Fernão Ferro",
//            "Sesimbra",
//            "Carrasqueira",
//            "Quintinhas",
//            "Cotovia",
//            "Santana"
//        ],
//        facilities: [],
//        shapeId: "p2_3536_0_1",
//        path: [],
//        trips: []
//    )
//    
//    
//    RouteDetailsView(route: route)
//}
