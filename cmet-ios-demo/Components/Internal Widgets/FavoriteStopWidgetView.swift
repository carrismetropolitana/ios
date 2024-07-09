//
//  FavoriteStopWidgetView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 14/03/2024.
//

import SwiftUI

struct FavoriteStopWidgetView: View {
    let stop: Stop?
    let patternIds: [String]
//    let estimates: [RealtimeETA]
    
    @State private var fullPatterns: [Pattern] = []
    @State private var stopEtas: [RealtimeETA] = []
    
    @State private var _______tempForUiDemoPurposes_isFavorited = true
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    if let stop = stop {
                        Text(stop.name)
                            .font(.callout)
                            .bold()
                    } else {
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.gray.opacity(0.4))
                            .frame(width: 100, height: 15)
                            .blinking()
                    }
                    
                    if let stop = stop {
                        Text(stop.locality == stop.municipalityName || stop.locality == nil ? stop.municipalityName : "\(stop.locality!), \(stop.municipalityName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
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
            .padding(.vertical, 15.0)
            .padding(.horizontal, 15.0)
            
            Rectangle()
                .fill(.gray.opacity(0.1))
                .frame(height: 3.0)
            
            ForEach(patternIds.indices, id: \.self) { patternIdIdx in
                let patternId = patternIds[patternIdIdx]
                
                if let pattern = fullPatterns.first(where: { $0.id == patternId }) {
                    HStack(alignment: .center) {
                        Pill(text: pattern.lineId, color: Color(hex: pattern.color), textColor: Color(hex: pattern.textColor), size: 60)
                        Image(systemName: "arrow.right")
                            .bold()
                            .scaleEffect(0.7)
                            .frame(width: 15)
                        Text(pattern.headsign)
                            .font(.headline)
                            .bold()
                        Spacer()
                    }
                    .padding(20.0)
                } else {
                    HStack(alignment: .center) {
                        Pill(text: "", color: .gray.opacity(0.6), textColor: .white, size: 60)
                            .blinking()
                        Image(systemName: "arrow.right")
                            .bold()
                            .scaleEffect(0.7)
                            .frame(width: 15)
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.gray.opacity(0.6))
                            .blinking()
                        Spacer()
                    }
                    .padding(20.0)
                }
                
                if patternIdIdx != patternIds.count - 1 {
                    Rectangle()
                        .fill(.gray.opacity(0.1))
                        .frame(height: 3.0)
                }
            }
            
//            Rectangle()
//                .fill(.gray.opacity(0.1))
//                .frame(height: 3.0)
//            
//            NavigationLink(destination: SmartNotificationCustomizationView()) {
//                HStack(alignment: .center) {
//                    Pill(text: "2042", color: Color(hex: "C61D23"), textColor: .white, size: 60)
//                    Image(systemName: "arrow.right")
//                        .bold()
//                        .scaleEffect(0.7)
//                        .frame(width: 15)
//                    Text("Alfornelos")
//                        .font(.title3)
//                        .bold()
//                    Spacer()
//                }
//                .padding(10.0)
//            }
            
        }
        .background(RoundedRectangle(cornerRadius: 15.0).fill(.white))
        .shadow(color: .gray.opacity(0.3), radius: 20)
        .onAppear {
            Task {
                try await loadPatterns()
            }
        }
        .onChange(of: patternIds) {
            Task {
                try await loadPatterns()
            }
        }
        .onChange(of: stop) {
            Task {
                if let stop = stop {
                    stopEtas = try await CMAPI.shared.getETAs(stop.id)
                    print("stop etas count: " + String(stopEtas.count))
                }
            }
        }
    }
    
    func loadPatterns () async throws {
        var patterns: [Pattern] = []
        for patternId in patternIds {
            let pattern = try await CMAPI.shared.getPattern(patternId)
            patterns.append(pattern)
        }
        
        fullPatterns = patterns
    }
}

//#Preview {
//    FavoriteStopWidgetView()
//        .shadow(color: .gray.opacity(0.3), radius: 20)
//        .padding()
//}
