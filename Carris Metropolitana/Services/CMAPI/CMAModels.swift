//
//  Models.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 14/03/2024.
//

import Foundation
import MapKit

enum Facility: String, Codable, Hashable {
    case school, boat, subway, train, hospital, shopping
    case transitOffice = "transit_office"
    case lightRail = "light_rail"
    case bikeSharing = "bike_sharing"
}

struct Line: Codable, Identifiable {
    let id: String
    let shortName: String
    let longName: String
    let ttsName: String?
    let color: String
    let textColor: String
    
    let routeIds: [String]
    let patternIds: [String]
    let municipalityIds: [String]
    let districtIds: [String]
    let localityIds: [String]
    let regionIds: [String]
    
    let facilities: [Facility]
    
    let stopIds: [String]
}



struct Route: Codable {
    let id: String
    let lineId: String
    let shortName: String
    let longName: String
    let ttsName: String?
    let color: String
    let textColor: String
    
    let patternIds: [String]
    let municipalityIds: [String]
    let districtIds: [String]
    let localityIds: [String]
    let regionIds: [String]
    
    let facilities: [Facility]
    
    let stopIds: [String]
}

struct Stop: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String?
    let ttsName: String?
    let operational_status: String?
    let lat: String
    let lon: String
    let locality: String?
    let parishId: String?
    let parishName: String?
    let municipalityId: String
    let municipalityName: String
    let districtId: String
    let districtName: String
    let regionId: String
    let regionName: String
    let wheelchairBoarding: String?
    let facilities: [Facility]
    let lines: [String]?
    let routes: [String]?
    let patterns: [String]?
    var nameNormalized: String?
    var ttsNameNormalized: String?
    
//    enum CodingKeys: String, CodingKey {
//        case id, name, latitude, longitude, locality
//        case shortName = "short_name"
//        case ttsName = "tts_name"
//        case parishId = "parish_id"
//        case parishName = "parish_name"
//        case municipalityId = "municipality_id"
//        case municipalityName = "municipality_name"
//        case districtId = "district_id"
//        case districtName = "district_name"
//        case regionId = "region_id"
//        case regionName = "region_name"
//        case wheelchairBoarding = "wheelchair_boarding"
//        case facilities, lines, routes, patterns
//    }
    
//    init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            id = try container.decode(String.self, forKey: .id)
//            name = try container.decode(String.self, forKey: .name)
//            ttsName = try container.decode(String.self, forKey: .ttsName)
//            latitude = try container.decode(String.self, forKey: .lat)
//            longitude = try container.decode(String.self, forKey: .lon)
//            locality = try container.decode(String.self, forKey: .locality)
//            municipalityID = try container.decode(String.self, forKey: .municipalityID)
//            municipalityName = try container.decode(String.self, forKey: .municipalityName)
//            districtID = try container.decode(String.self, forKey: .districtID)
//            districtName = try container.decode(String.self, forKey: .districtName)
//            regionID = try container.decode(String.self, forKey: .regionID)
//            regionName = try container.decode(String.self, forKey: .regionName)
//            facilities = try container.decode([String].self, forKey: .facilities)
//            lines = try container.decode([String].self, forKey: .lines)
//            routes = try container.decode([String].self, forKey: .routes)
//            patterns = try container.decode([String].self, forKey: .patterns)
//        }
}

struct PathEntry: Codable, Hashable  {
    let stop: Stop
    let stopSequence: Int
    let allowPickup: Bool
    let allowDropOff: Bool
    let distanceDelta: Double
    
//    enum CodingKeys: String, CodingKey {
//        case stop
//        case stopSequence = "stop_sequence"
//        case allowPickup = "allow_pickup"
//        case allowDropOff = "allow_drop_off"
//        case distanceDelta = "distance_delta"
//    }
}

struct ScheduleEntry: Codable, Hashable {
    let stopId: String
    let stopSequence: Int
    let arrivalTime: String
    let arrivalTimeOperation: String
    // let travelTime: String // TODO: ATTN -- or Int in case of 0 (first stop); currently ignored as its not used anywhere yet
}

struct Trip: Codable, Hashable {
    let id: String? // TODO: ask about this (also no path was available, maybe some parsing was happening at the time?)
    let calendarId: String
    let calendarDescription: String
    let dates: [String]
    let schedule: [ScheduleEntry]
}


struct Pattern: Codable, Identifiable, Hashable {
    let id: String
    let lineId: String
    let routeId: String
    let shortName: String
    let direction: Int
    let headsign: String
    let color: String
    let textColor: String
    let validOn: [String]
    let municipalities: [String]
    let localities: [String?]
    let facilities: [String]
    let shapeId: String
    let path: [PathEntry]
    let trips: [Trip]
}


struct GeoJSON: Codable { // TODO: figure out if can use MKGeoJSONObject or MKGeoJSONFeature
    let type = "Feature"
//    let properties
    let geometry: Geometry
    
    struct Geometry: Codable {
        let type = "LineString"
        let coordinates: [[Double]]
    }
}

struct CMShape: Codable { // stick all this into a common parent
    let id: String
    let points: [ShapePoint]
    let geojson: GeoJSON
    let _extension: Int
    
    
    struct ShapePoint: Codable {
        let shapePtLat: Double
        let shapePtLon: Double
        let shapePtSequence: Int
        let shapeDistTraveled: Double
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id, points, geojson
        case _extension = "extension"
    }
}


struct RealtimeETA: Codable, Hashable {
    let lineId: String
    let patternId: String
    let routeId: String
    let tripId: String
    let headsign: String
    let stopSequence: Int
    let scheduledArrival: String?
    let scheduledArrivalUnix: Int?
    let estimatedArrival: String?
    let estimatedArrivalUnix: Int?
    let observedArrival: String?
    let observedArrivalUnix: Int?
    let vehicleId: String?
}

struct PatternRealtimeETA: Codable, Hashable {
    let stopId: String
    let lineId: String
    let patternId: String
    let routeId: String
    let tripId: String
    let headsign: String
    let stopSequence: Int
    let scheduledArrival: String?
    let scheduledArrivalUnix: Int?
    let estimatedArrival: String?
    let estimatedArrivalUnix: Int?
    let observedArrival: String?
    let observedArrivalUnix: Int?
    let vehicleId: String?
}

struct Vehicle: Codable, Identifiable, Equatable {
    let id: String
    let timestamp: Int
    let scheduleRelationship: String
    let tripId: String
    let patternId: String
    let routeId: String
    let lineId: String
    let stopId: String
    let currentStatus: String
    let blockId: String
    let shiftId: String
    let lat: Double
    let lon: Double
    let bearing: Int
    let speed: Double
}

/**
 The vehicles endpoint now returns all vehicles with metadata including ones without any realtime data.
 
 
 */
struct VehicleV2: Codable, Identifiable, Equatable {
    let id: String
    let bikesAllowed: Bool?
    let capacitySeated: Int?
    let capacityStanding: Int?
    let capacityTotal: Int?
    let emissionClass: String?
    let licensePlate: String?
    let make: String?
    let model: String?
    let owner: String?
    let propulsion: String?
    let registrationDate: String?
    let wheelchairAccessible: Bool?
    let agencyId: String?
    let timestamp: Int?
    let scheduleRelationship: String?
    let tripId: String?
    let patternId: String?
    let routeId: String?
    let lineId: String?
    let stopId: String?
    let currentStatus: String?
    let blockId: String?
    let shiftId: String?
    let lat: Double?
    let lon: Double?
    let bearing: Int?
    let speed: Double?
    let eventId: String?
    let occupancyEstimated: Int?
    let occupancyStatus: String?
    let doorStatus: DoorStatus?
    
    enum DoorStatus: String, Codable {
        case open = "OPEN"
        case closed = "CLOSED"
    }
    
    var isRealtime: Bool {
        return timestamp != nil
    }
}

extension Array where Element == VehicleV2 {
    var realtimeVehicles: [VehicleV2] {
        return self.filter { $0.isRealtime && Int(Date.now.timeIntervalSince1970) - $0.timestamp! <= 180 }
    }
}

struct ENCM: Codable, Identifiable {
    let id: String
    let name: String
    let lat: String
    let lon: String
    let phone: String
    let email: String
    let url: String
    let address: String
    let postalCode: String
    let locality: String
    let parishId: String
    let parishName: String
    let municipalityId: String
    let municipalityName: String
    let districtId: String
    let districtName: String
    let regionId: String
    let regionName: String
    let hoursMonday: [String]
    let hoursTuesday: [String]
    let hoursWednesday: [String]
    let hoursThursday: [String]
    let hoursFriday: [String]
    let hoursSaturday: [String]
    let hoursSunday: [String]
    let hoursSpecial: String
    let stops: [String]
    let currentlyWaiting: Int
    let expectedWaitTime: Int
    let activeCounters: Int
    let isOpen: Bool
}

struct GtfsRtAlert: Identifiable, Codable, Equatable {
    static func == (lhs: GtfsRtAlert, rhs: GtfsRtAlert) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        return alertId
    }
    
    let alertId: String
    let activePeriod: [ActivePeriod]
    let cause: Cause
    let descriptionText: TranslatedString
    let effect: Effect
    let headerText: TranslatedString
    let informedEntity: [EntitySelector]
    let url: TranslatedString
    let image: TranslatedImage?
    
    struct ActivePeriod: Codable {
        let start: Int?
        let end: Int?

        private enum CodingKeys: String, CodingKey {
            case start, end
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            func decodeInt(forKey key: CodingKeys) throws -> Int? {
                if let intVal = try? container.decode(Int.self, forKey: key) {
                    return intVal
                } else if let doubleVal = try? container.decode(Double.self, forKey: key) {
                    return Int(doubleVal)
                } else {
                    return nil
                }
            }

            start = try decodeInt(forKey: .start)
            end = try decodeInt(forKey: .end)
        }
    }
    
    struct TranslatedString: Codable {
        let translation: [Translation]
        
        struct Translation: Codable {
            let text: String
            let language: String
        }
    }
    
    struct TranslatedImage: Codable {
        let localizedImage: [LocalizedImage]
        
        struct LocalizedImage: Codable {
            let url: String
            let mediaType: String
            let language: String
        }
    }
    
    struct EntitySelector: Codable {
        let agencyId: String?
        let routeId: String?
        let routeType: Int?
        let directionId: Int?
        //        let trip: TripDescriptor? // @see GTFS-RT Reference, not used in CM
        let stopId: String?
    }
    
    enum Cause: String, Codable {
        case unknownCause = "UNKNOWN_CAUSE"
        case otherCause = "OTHER_CAUSE"
        case technicalProblem = "TECHNICAL_PROBLEM"
        case strike = "STRIKE"
        case demonstration = "DEMONSTRATION"
        case accident = "ACCIDENT"
        case holiday = "HOLIDAY"
        case weather = "WEATHER"
        case maintenance = "MAINTENANCE"
        case construction = "CONSTRUCTION"
        case policeActivity = "POLICE_ACTIVITY"
        case medicalEmergency = "MEDICAL_EMERGENCY"
    }
    
    enum Effect: String, Codable {
        case noService = "NO_SERVICE"
        case reducedService = "REDUCED_SERVICE"
        case significantDelays = "SIGNIFICANT_DELAYS"
        case detour = "DETOUR"
        case additionalService = "ADDITIONAL_SERVICE"
        case modifiedService = "MODIFIED_SERVICE"
        case otherEffect = "OTHER_EFFECT"
        case unknownEffect = "UNKNOWN_EFFECT"
        case stopMoved = "STOP_MOVED"
        case noEffect = "NO_EFFECT"
        case accessibilityIssue = "ACCESSIBILITY_ISSUE"
    }
}
