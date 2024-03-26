//
//  VehiclesManager.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 08/06/2024.
//

import Foundation

class VehiclesManager: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    private var timer: Timer?

    init() {
        print("VehiclesManager got instantiated!")
        fetchVehicles()
        print("Vehicles: \(vehicles.count)")
    }

    func fetchVehicles() {
        Task {
            do {
                let newVehicles = try await CMAPI.shared.getVehicles()
                DispatchQueue.main.async {
                    self.vehicles = newVehicles
                    print("Got \(newVehicles.count) new vehicles!, \(Date.now)")
                }
            } catch {
                print("Failed to fetch vehicles!")
                print(error)
            }
        }
    }

    func startFetching() {
        if (timer == nil) {
            self.fetchVehicles()
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                self.fetchVehicles()
            }
        }
    }
    
    func stopFetching() {
        // Invalidate the timer to stop fetching
        timer?.invalidate()
        timer = nil
    }
}
