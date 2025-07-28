//
//  AlertsManager.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 07/06/2024.
//

import Foundation

class AlertsManager: ObservableObject {
    @Published var alerts: [GtfsRtAlert] = []


    init() {
        print("AlertsManager got instantiated!")
        fetchAlerts()
        setupAutoRefresh()
        print("Alerts: \(alerts.count)")
    }

    func fetchAlerts() {
        Task {
            let newAlerts = await CMAPI.shared.getAlerts()
            DispatchQueue.main.async {
                self.alerts = newAlerts
                print("Got \(newAlerts.count) new alerts!")
            }
        }
    }

    private func setupAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.fetchAlerts()
        }
    }
}
