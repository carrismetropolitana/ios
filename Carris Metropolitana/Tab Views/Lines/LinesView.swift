//
//  LinesView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI
import CoreLocation

struct LinesView: View {
    @EnvironmentObject var linesManager: LinesManager
    @EnvironmentObject var vehiclesManager: VehiclesManager
//    @State private var lines: [Line] = []
    @State private var searchTerm = ""
    var body: some View {
        NavigationStack {
            ZStack {
                VStack (alignment: .leading, spacing: 0) {
//                    VStack(alignment: .center, spacing: 20) {
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text("Pesquisar Linhas")
//                                    .bold()
//                                    .font(.title)
//                                Text("Encontre a sua linha lorem ipsum dolor sit amet.")
//                                    .font(.callout)
//                            }
//                            Spacer()
//                        }
//                        VStack(alignment: .center) {
//                            HStack{
//                                Image(systemName: "magnifyingglass")
//                                    .foregroundStyle(.gray)
//                                    .padding(.leading, 20)
//                                    .padding(.trailing, 10)
//                                TextField("", text: $searchTerm, prompt: Text("Nome ou número da linha").foregroundColor(.gray).fontWeight(.semibold))
//                                    .padding(.vertical, 18)
//                                
//                            }
//                            .background(Color.white.opacity(0.7))
//                            .cornerRadius(15)
//                        }
//                    }
//                    .padding()
//                    .background(.cmYellow)
                    
                    LinesListView(lines: linesManager.lines, searchTerm: $searchTerm)
                }
            }
//            .navigationTitle("Pesquisar Linhas")
            .navigationTitle("Linhas")
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Nome ou número da linha")
            .toolbarBackground(.cmYellow, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light)
            .onAppear {
                vehiclesManager.stopFetching()
            }
            // .toolbar(.hidden) // for now, default title too big
//            .onAppear {
//                if lines.count == 0 {
//                    Task {
//                        lines = await CMAPI.shared.getLines()
//                        print(lines.count)
//                    }
//                }
//            }
        }
    }
}

#Preview {
    LinesView()
}

struct LinesListView: View {
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var searchHistoryManager = LinesSearchHistoryManager.shared
    
    
    @EnvironmentObject var stopsManager: StopsManager
    @EnvironmentObject var linesManager: LinesManager
    
    
    @Environment(\.isSearching) var isSearching
    @State var lines: [Line]
    @Binding var searchTerm: String
    @State private var searchFilteredLines: [Line] = []
    
    var onClickOverride: ((_ lineId: String) -> Void)? = nil
    
    var body: some View {
        List {
            if !isSearching {
                if searchHistoryManager.searchHistory.count > 0 {
                    Section(header: HStack {
                        Text("Recentes").bold().font(.title2).foregroundStyle(.windowBackground).offset(x:-15).colorInvert()
                        Spacer()
                        Button() {
                            withAnimation {
                                searchHistoryManager.wipeSearchHistory()
                            }
                        } label: {
                            Text("Limpar")
                                .font(.caption)
                                .padding(.horizontal, 5.0)
                                .padding(.vertical, 2.0)
                                .background {
                                    Capsule()
                                        .stroke(.gray, lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }) {
                        ForEach(searchHistoryManager.searchHistory, id: \.self) { lineId in
                            let line = lines.first { $0.id == lineId }
                            
                            if let line = line {
                                if let onClickOverride = onClickOverride {
                                    Button {
                                        onClickOverride(line.id)
                                    } label: {
                                        LineEntry(line: line)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(Text("Linha \(line.shortName), \(line.longName)", comment: "Botão, Detalhes da linha"))
                                } else {
                                    NavigationLink(destination: LineDetailsView(line: line, overrideDisplayedPatternId: nil)) {
                                        LineEntry(line: line)
                                    }
                                    .accessibilityLabel(Text("Linha \(line.shortName), \(line.longName)", comment: "Botão, Detalhes da linha"))
                                }
                            }
                        }
                    }
                    .textCase(nil)
                    .listRowBackground(Color.cmSystemBackground100)
                    .listRowSeparatorTint(Color.cmSystemBorder100)
                }
                
                if onClickOverride == nil {
                    if let location = locationManager.location {
                        aroundMeLines(location.coordinate)
                    }
                }
            }
            Section(header: isSearching ? nil :  Text("Todas as Linhas").bold().font(.title2).foregroundStyle(.windowBackground).offset(x: -15).colorInvert()) {
                ForEach(isSearching ? searchFilteredLines : lines) { line in
                    if let onClickOverride = onClickOverride {
                        Button {
                            onClickOverride(line.id)
                        } label: {
                            LineEntry(line: line)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Linha \(line.shortName), \(line.longName)", comment: "Botão, Detalhes da linha"))
                    } else {
                        NavigationLink(destination: LineDetailsView(line: line, overrideDisplayedPatternId: nil)) {
                            LineEntry(line: line)
                        }
                        .accessibilityLabel(Text("Linha \(line.shortName), \(line.longName)", comment: "Botão, Detalhes da linha"))
                    }
                }
            }
            .textCase(nil)
            .listRowBackground(Color.cmSystemBackground100)
            .listRowSeparatorTint(Color.cmSystemBorder100)
        }
        .background(.cmSystemBackground200)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, isSearching ? 25 : 0, for: .scrollContent)
        .onChange(of: isSearching) {
            if searchFilteredLines.count == 0 {
                searchFilteredLines = lines
            }
        }
        .onChange(of: searchTerm) {
            print(searchTerm)
            let filtered = lines.filter {
                $0.longName.localizedCaseInsensitiveContains(searchTerm) || $0.shortName.localizedCaseInsensitiveContains(searchTerm)
            }
            if filtered.count > 0 {
                searchFilteredLines = filtered
            } else {
                searchFilteredLines = lines
            }
        }
    }
    
    private func aroundMeLines(_ location: CLLocationCoordinate2D) -> some View {
        let linesAroundUser = closestStops(to: location, stops: stopsManager.stops, maxResults: 3, needsLines: true).compactMap { $0.lines![0] }
        return (
            Section(header: Text("À Minha Volta").bold().font(.title2).foregroundStyle(.windowBackground).offset(x: -15).colorInvert()) {
                
                //                        ForEach(closestStops(to: location, stops: [Stop]))
                ForEach (linesAroundUser, id: \.self) { lineId in
                    let line = linesManager.lines.first { $0.id == lineId }!
                    NavigationLink(destination: LineDetailsView(line: line, overrideDisplayedPatternId: nil)) {
                        LineEntry(line: line)
                    }
                    .accessibilityLabel(Text("Linha \(line.shortName), \(line.longName)", comment: "Botão, Detalhes da linha"))
                }
//                Text("Location")
//                    .badge(Text("\(location.latitude), \(location.longitude)"))
            }
            .textCase(nil)
            .listRowBackground(Color.cmSystemBackground100)
            .listRowSeparatorTint(Color.cmSystemBorder100)

        )
    }
    
    
}

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
//        print(cleanHexCode)
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}

#Preview {
    VStack {
        Pill(text: "1523", color: .red, textColor: .white, size: .large)
    }
}

enum PillSize {
    case normal, large
}

struct Pill: View {
    let text: String
    let color: Color
    let textColor: Color
    var size: PillSize = .normal
    
    var body: some View {
        Text(text)
            .font(.system(size: size == .normal ? 18.0 : 24.0))
            .foregroundStyle(textColor)
            .fontWeight(.heavy)
            .frame(
                width: size == .normal ? 65.0 : 85.0
            )
            .background {
                RoundedRectangle(cornerRadius: 20.0)
                    .frame(height: size == .normal ? 26.0 : 34.0)
                    .foregroundStyle(color)
            }
    }
    
}

//struct RouteEntry: View {
//    let route: Route
//    var body: some View {
//        HStack {
//            Pill(text: route.shortName, color: .init(hex: route.color), textColor: .init(hex: route.textColor))
//            Text(route.longName)
//                .bold()
//                .font(.subheadline)
//                .lineLimit(2)
//            Spacer()
//            Image(systemName: "chevron.right")
//                .foregroundStyle(.gray.secondary)
//        }
//        .frame(height: 40)
//        .padding(.vertical, 5)
//        
//    }
//}

struct LineEntry: View {
    let line: Line
    var body: some View {
        HStack {
            Pill(text: line.shortName, color: .init(hex: line.color), textColor: .init(hex: line.textColor))
                .padding(.horizontal, 5.0)
            Text(line.longName)
                .bold()
                .font(.subheadline)
                .lineLimit(2)
            Spacer()
//            Image(systemName: "chevron.right")
//                .foregroundStyle(.gray.secondary)
        }
        .frame(height: 40)
//        .padding(.vertical, 5)
    }
}

/* This should all be in another file —— was positioned here for now for easier debugging **/

extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371000.0 // Earth's radius in meters
        
        let dLat = (coordinate.latitude - self.latitude).degreesToRadians
        let dLon = (coordinate.longitude - self.longitude).degreesToRadians
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(self.latitude.degreesToRadians) * cos(coordinate.latitude.degreesToRadians) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
}


func closestStops(to location: CLLocationCoordinate2D, stops: [Stop], maxResults: Int = 3, needsLines: Bool? = nil) -> [Stop] {
    var sortedStops = stops.sorted {
        let location1 = CLLocationCoordinate2D(latitude: Double($0.lat) ?? 0, longitude: Double($0.lon) ?? 0)
        let location2 = CLLocationCoordinate2D(latitude: Double($1.lat) ?? 0, longitude: Double($1.lon) ?? 0)
        return location.distance(to: location1) < location.distance(to: location2)
    }
    
    if let needsLines = needsLines {
        if needsLines {
            sortedStops = sortedStops.filter {
                if let lines = $0.lines {
                    return lines.count > 0
                }
                return false
            }
        }
    }
    
    return Array(Set(sortedStops.prefix(maxResults)))
}

