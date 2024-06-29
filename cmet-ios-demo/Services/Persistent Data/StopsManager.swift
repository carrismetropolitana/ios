//
//  StopsManager.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 29/06/2024.
//

import Foundation

class StopsManager: ObservableObject {
    @Published var stops: [Stop] = []


    init() {
        print("StopsManager got instantiated!")
        fetchStops()
        setupAutoRefresh()
        print("Stops: \(stops.count)")
    }

    func fetchStops() {
        Task {
            let newStops = await CMAPI.shared.getStops()
            DispatchQueue.main.async {
                self.stops = newStops
                print("Got \(newStops.count) new stops!")
            }
        }
    }

    private func setupAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 60*10, repeats: true) { _ in
            self.fetchStops()
        }
    }
}
