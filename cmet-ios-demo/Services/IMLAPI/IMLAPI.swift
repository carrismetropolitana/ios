//
//  IMLAPI.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 29/03/2024.
//

enum IMLAPIError: Error {
    case noStopFound
}

class IMLAPI { // this also does not support Last-Modified-Since so i guess just get the routes and update cache very now and then (every minute?)
    private static let baseUrl = "https://api.intermodal.pt/v1"
    private static let cmOperatorId = 1
    
    static let shared = IMLAPI()
    
    func getStopByOperatorId(_ operatorId: Int = cmOperatorId, stopId: String) async throws -> IMLStop {
        var stops: [IMLStop] = []
        do {
            stops = try await NetworkService.makeGETRequest("\(IMLAPI.baseUrl)/operators/\(operatorId)/stop_by_ref/\(stopId)", responseType: [IMLStop].self)
        } catch {
            print("Failed to fetch stop by ref from IML!")
            print(error)
        }
        
        guard stops.count > 0 else {
            throw IMLAPIError.noStopFound
        }
        
        return stops[0]
    }
    
    func getStopPictures(_ stopId: Int) async -> [IMLPicture] {
        var pictures: [IMLPicture] = []
        do {
            pictures = try await NetworkService.makeGETRequest("\(IMLAPI.baseUrl)/stops/\(stopId)/pictures", responseType: [IMLPicture].self)
        } catch {
            print("Failed to fetch stop pics from IML!")
            print(error)
        }
        
        return pictures
    }
}
