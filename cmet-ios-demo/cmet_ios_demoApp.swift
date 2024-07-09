//
//  cmet_ios_demoApp.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI

@main
struct cmet_ios_demoApp: App {
    @StateObject private var alertsManager = AlertsManager()
    @StateObject private var vehiclesManager = VehiclesManager()
    @StateObject private var linesManager = LinesManager()
    @StateObject private var stopsManager = StopsManager()
    
    @StateObject private var favoritesManager = FavoritesManager()
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertsManager)
                .environmentObject(vehiclesManager)
                .environmentObject(locationManager)
                .environmentObject(linesManager)
                .environmentObject(stopsManager)
                .environmentObject(favoritesManager)
                .onAppear {
                    UINavigationBar.appearance().prefersLargeTitles = true
                }
//            ErrorBannerDemo()
//            TestPreview()
//            OtherTestPreview()
//            NewsView()
        }
    }
}
