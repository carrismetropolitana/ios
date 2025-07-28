//
//  RoutesManager.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 28/07/2025.
//

import Foundation

class RoutesManager: ObservableObject {
    @Published var routes: [Route] = []


    init() {
        print("RoutesManager got instantiated!")
        fetchLines()
        setupAutoRefresh()
        print("Routes: \(routes.count)")
    }

    func fetchLines() {
        Task {
            let newRoutes = await CMAPI.shared.getRoutes()
            DispatchQueue.main.async {
                self.routes = newRoutes
                print("Got \(newRoutes.count) new routes!")
            }
        }
    }

    private func setupAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 60*5, repeats: true) { _ in
            self.fetchLines()
        }
    }
}
