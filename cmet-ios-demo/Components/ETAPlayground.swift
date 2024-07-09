//
//  ETAPlayground.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 08/07/2024.
//

import SwiftUI

struct ETAPlayground: View {
    //    @State private var etas: [PatternRealtimeETA] = []
    @State private var stopIdsWithEtas: [String: [PatternRealtimeETA]] = [:]
    
    var body: some View {
        List {
            ForEach(Array(stopIdsWithEtas.keys), id: \.self) { stopId in
//                let etas = stopIdsWithEtas[stopId]!
                Text(stopId)
//                Section(header: Text("Stop \(stopId)")) {
//                    ForEach(etas) { eta in
//                        VStack(alignment: .leading) {
//                            Text("STOP " + eta.stopId)
//                                .font(.title2)
//                                .bold()
//                            Text("Scheduled: " + (eta.scheduledArrival ?? "UNAVAILABLE"))
//                                .font(.title3)
//                            Text("Estimated: " + (eta.estimatedArrival ?? "UNAVAILABLE"))
//                                .font(.title3)
//                            Text("Observed: " + (eta.observedArrival ?? "UNAVAILABLE"))
//                                .font(.title3)
//                        }
//                    }
//                }
            }
        }
        .onAppear {
            Task {
                let etas = try await CMAPI.shared.getETAs(patternId: "3710_0_1")
                stopIdsWithEtas = arrangeByStopIds(etas)
                
            }
        }
    }
}


func arrangeByStopIds(_ patternEtas: [PatternRealtimeETA]) -> [String: [PatternRealtimeETA]] {
    var arrangedDict = [String: [PatternRealtimeETA]]()
    
    for eta in patternEtas {
        if arrangedDict[eta.stopId] != nil {
            arrangedDict[eta.stopId]?.append(eta)
        } else {
            arrangedDict[eta.stopId] = [eta]
        }
    }
    
    return arrangedDict
}

#Preview {
    ETAPlayground()
}
