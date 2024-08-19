//
//  MapDemoSwiftUI.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 10/05/2024.
//

import SwiftUI
import MapLibre

struct MapDemoSwiftUI: View {
    let styleURL = URL(string: "https://maps.carrismetropolitana.pt/styles/default/style.json")
    var body: some View {
        Text("hi")
//        MLNMapView(frame: .zero, styleURL: styleURL)
    }
}

#Preview {
    MapDemoSwiftUI()
}
