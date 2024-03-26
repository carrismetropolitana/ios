//
//  CMAPI.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 14/03/2024.
//

import Foundation

enum CMAPIError: Error {
    case noRouteFound
}

class CMAPI { // this also does not support Last-Modified-Since so i guess just get the routes and update cache very now and then (every minute?)
    private static let baseUrl = "https://api.carrismetropolitana.pt"
    private static let alertsUrl = "\(baseUrl)/alerts"
    private static let linesUrl = "\(baseUrl)/lines"
    private static let routesUrl = "\(baseUrl)/routes"
    private static let patternsUrl = "\(baseUrl)/patterns"
    private static let shapesUrl = "\(baseUrl)/shapes"
    private static let stopsUrl = "\(baseUrl)/stops"
    private static let vehiclesUrl = "\(baseUrl)/vehicles"
    private static let facilitiesUrl = "\(baseUrl)/datasets/facilities"
    
    static let shared = CMAPI()
    
    func getAlerts() async throws -> [GtfsRtAlertEntity] {
        var alerts: [GtfsRtAlertEntity] = []
        
        do {
            var fullDataset = try await NetworkService.makeGETRequest(CMAPI.alertsUrl, responseType: GtfsRt.self)
//            if let alerts = fullDataset.entity { // consider nil edgecase
//
//            }
            alerts = fullDataset.entity
            
        } catch {
            print("Failed to fetch alerts!")
            print(error)
        }
        
        guard alerts.count > 0 else {
            throw CMAPIError.noRouteFound
        }
        
        return alerts
    }
    
    func getStops() async -> [Stop] {
        var stops: [Stop] = []
        do {
            stops = try await NetworkService.makeGETRequest(CMAPI.stopsUrl, responseType: [Stop].self)
        } catch {
            print("Failed to fetch stops!")
            print(error)
        }
        
        return stops
    }
    
    func getLines() async -> [Line] {
        var lines: [Line] = []
        do {
            lines = try await NetworkService.makeGETRequest(CMAPI.linesUrl, responseType: [Line].self)
        } catch {
            print("Failed to fetch lines!")
            print(error)
        }
        
        return lines
    }
    
    func getRoute(_ routeId: String) async throws -> Route {
        var route: Route?
        do {
            route = try await NetworkService.makeGETRequest("\(CMAPI.routesUrl)/\(routeId)", responseType: Route.self)
        } catch {
            print("Failed to fetch route \(routeId)!")
            print(error)
        }
        
        guard route != nil else {
            throw CMAPIError.noRouteFound
        }
        
        return route!
    }
    
    func getPattern(_ patternId: String) async throws -> Pattern {
        var pattern: Pattern?
        do {
            pattern = try await NetworkService.makeGETRequest("\(CMAPI.patternsUrl)/\(patternId)", responseType: Pattern.self)
        } catch {
            print("Failed to fetch pattern \(patternId)!")
            print(error)
        }
        
        guard pattern != nil else {
            throw CMAPIError.noRouteFound
        }
        
        return pattern!
    }
    
    func getETAs(_ stopId: String) async throws -> [RealtimeETA] {
        var etas: [RealtimeETA]?
        do {
            etas = try await NetworkService.makeGETRequest("\(CMAPI.stopsUrl)/\(stopId)/realtime", responseType: [RealtimeETA].self)
        } catch {
            print("Failed to fetch realtime estimates for stop \(stopId)!")
            print(error)
        }
        
        guard etas != nil else {
            throw CMAPIError.noRouteFound
        }
        
        return etas!
    }
    
    func getVehicles() async throws -> [Vehicle] {
        var vehicles: [Vehicle]?
        
        do {
            vehicles = try await NetworkService.makeGETRequest(CMAPI.vehiclesUrl, responseType: [Vehicle].self)
        } catch {
            print("Failed to fetch vehicles!")
            print(error)
        }
        
        guard vehicles != nil else {
            throw CMAPIError.noRouteFound
        }
        
        return vehicles!
    }
    
    func getENCM() async throws -> [ENCM] {
        var encm: [ENCM]?
        
        do {
            encm = try await NetworkService.makeGETRequest("\(CMAPI.facilitiesUrl)/encm", responseType: [ENCM].self)
        } catch {
            print("Failed to fetch ENCMs!")
            print(error)
        }
        
        guard encm != nil else {
            throw CMAPIError.noRouteFound
        }
        
        return encm!
        
    }
    
    func getShape(_ shapeId: String) async throws -> CMShape {
        var shape: CMShape?
        
        do {
            shape = try await NetworkService.makeGETRequest("\(CMAPI.shapesUrl)/\(shapeId)", responseType: CMShape.self)
        } catch {
            print("Failed to fetch ENCMs!")
            print(error)
        }
        
        guard shape != nil else {
            throw CMAPIError.noRouteFound
        }
        
        return shape!
        
    }
    
}
