//
//  ENCMView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 16/03/2024.
//

import SwiftUI

struct ENCMView: View {
    @State private var timer: Timer?
    
    @State private var encms: [ENCM] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: "https://www.navegante.pt/assets/94954915-432c-4a56-8157-c8b2c94e793d?access_token=utilizador.rest")){ image in
                    image.resizable()
                } placeholder: { Color.gray }
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                
                    Text("Dedicados ao passageiro, os chamados Espaços navegante® Carris Metropolitana, concentram todos os serviços relacionados com a Carris Metropolitana, possibilitando esclarecer dúvidas, solicitar a emissão de cartões navegante® ou mesmo aderir ao passe navegante família e antigo combatente.")
                        .font(.subheadline)
                        .padding()
                    
                    ForEach(encms) { encm in
                        VStack(alignment: .leading) {
                            Group {
                                Text(encm.name.dropFirst(39))
                                    .bold()
                                    .font(.title2)
                                    .padding(.vertical, 5)
                                Text("Morada".uppercased())
                                    .fontWeight(.heavy)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(encm.address)
                                    .padding(.bottom, 5)
                                Text("Horário".uppercased())
                                    .fontWeight(.heavy)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(encmToHoursOpenString(encm))
                                
                                if !encm.isOpen {
                                    Pill(text: "Fechado/Completo".uppercased(), color: .red, textColor: .primary, size: 200)
                                        .padding(.vertical)
//                                    Text("Fechado/Completo".uppercased())
//                                        .font(.headline)
//                                        .foregroundStyle(.red)
//                                        .padding(.top, 10.0)
                                } else {
                                    //                                    HStack {
                                    //                                        VStack {
                                    //                                            Text("Em espera".uppercased())
                                    //                                                .fontWeight(.heavy)
                                    //                                                .font(.caption)
                                    //                                                .foregroundStyle(.secondary)
                                    //                                            Text(String(encm.currentlyWaiting))
                                    //                                        }
                                    //
                                    //                                        VStack {
                                    //                                            Text("Tempo de espera estimado".uppercased())
                                    //                                                .fontWeight(.heavy)
                                    //                                                .font(.caption)
                                    //                                                .foregroundStyle(.secondary)
                                    //                                            Text("\(String(Int(encm.expectedWaitTime/60))) min")
                                    //                                        }
                                    //                                    }
                                    OpenENCMCapsule(currentlyWaiting: encm.currentlyWaiting, expectedWaitTime: encm.expectedWaitTime)
                                        .padding(.vertical)
                                }
                            }
                            .padding(.horizontal)
                            Divider()
                        }
                    }
    
            }
        }
        .navigationTitle("Espaços navegante®")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchENCM()
            
            startFetchingTimer()
        }
        .onDisappear {
            stopFetchingTimer()
        }
    }
    
    func fetchENCM() {
        Task {
            encms = try await CMAPI.shared.getENCM()
        }
    }
    
    private func startFetchingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            fetchENCM()
        }
    }
    
    private func stopFetchingTimer() {
        // Invalidate the timer to stop fetching
        timer?.invalidate()
        timer = nil
    }
}


struct ENCMTimetableEntry {
    var dayOfTheWeek: Weekday
    let hourIntervals: [String]
}


func encmToHoursOpenString(_ encm: ENCM) -> String {
    var timetable: [ENCMTimetableEntry] = []
    
    timetable.append(.init(dayOfTheWeek: .monday, hourIntervals: encm.hoursMonday))

    timetable.append(.init(dayOfTheWeek: .tuesday, hourIntervals: encm.hoursTuesday))
    
    timetable.append(.init(dayOfTheWeek: .wednesday, hourIntervals: encm.hoursWednesday))

    timetable.append(.init(dayOfTheWeek: .thursday, hourIntervals: encm.hoursThursday))

    timetable.append(.init(dayOfTheWeek: .friday, hourIntervals: encm.hoursFriday))

    timetable.append(.init(dayOfTheWeek: .saturday, hourIntervals: encm.hoursSaturday))

    timetable.append(.init(dayOfTheWeek: .sunday, hourIntervals: encm.hoursSunday))
    
    let equalToMonday = timetable.filter({$0.hourIntervals == encm.hoursMonday})
    
    var timeIntervals = ""
    
    for hourIntervalIdx in encm.hoursMonday.indices {
        let hourInterval = encm.hoursFriday[hourIntervalIdx]
        let isLast = hourIntervalIdx == encm.hoursMonday.count - 1
        
        timeIntervals += hourInterval + (isLast ? "" : "\n")
    }
    return "\(equalToMonday.first!.dayOfTheWeek.rawValue)-\(equalToMonday.last!.dayOfTheWeek.rawValue)\n\(timeIntervals)"
}

struct OpenENCMCapsule: View {
    let currentlyWaiting: Int
    let expectedWaitTime: Int
    
    var body: some View {
        HStack {
            Text("\(Image(systemName: "person.2.fill"))  \(currentlyWaiting) em espera")
                .fontWeight(.bold)
                .padding(.horizontal, 10.0)
                .background(Capsule().fill(.white))
            Text("\(Image(systemName: "clock.fill"))  \(expectedWaitTime/60) min")
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 5.0)
        }
        .padding(5.0)
        .background(Capsule().fill(.green))
    }
}

#Preview {
    ENCMView()
}
