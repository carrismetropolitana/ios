//
//  ArrivalsHelpers.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 26/08/2024.
//

import Foundation

func filterAndSortCurrentAndFutureStopETAs(_ etas: [RealtimeETA]) -> [RealtimeETA] {
    let currentAndFutureFiltering = etas.filter({
        let tripHasObservedArrival = $0.observedArrivalUnix != nil
        let tripScheduledArrivalIsInThePast = $0.scheduledArrivalUnix ?? 0 <= Int(Date().timeIntervalSince1970)
        let tripHasEstimatedArrival = $0.estimatedArrivalUnix != nil
        let tripEstimatedArrivalIsInThePast = $0.estimatedArrivalUnix ?? 0 <= Int(Date().timeIntervalSince1970)
        
        if tripScheduledArrivalIsInThePast {
            return false
        }
        
        if tripHasEstimatedArrival && tripEstimatedArrivalIsInThePast {
            return false
        }
        
        if tripHasObservedArrival {
            return false
        }
        
        return true
    })
    
    print("Filtered \(currentAndFutureFiltering.count) ETAs as currentAndFuture.")
    
    let sorted = currentAndFutureFiltering.sorted { (a, b) -> Bool in
        if let estimatedArrivalA = a.estimatedArrivalUnix, let estimatedArrivalB = b.estimatedArrivalUnix {
            // Both have estimated_arrival, compare them
            return estimatedArrivalA < estimatedArrivalB
        } else if a.estimatedArrivalUnix != nil {
            // Only `a` has estimated_arrival, so it comes before `b`
            return true
        } else if b.estimatedArrivalUnix != nil {
            // Only `b` has estimated_arrival, so it comes before `a`
            return false
        } else {
            // Both have only scheduled_arrival, compare them
            return a.scheduledArrivalUnix! < b.scheduledArrivalUnix!
        }
    }
    
    return sorted
}

func filterAndSortCurrentAndFuturePatternETAs(_ etas: [PatternRealtimeETA]) -> [PatternRealtimeETA] {
    let currentAndFutureFiltering = etas.filter({
        let tripHasObservedArrival = $0.observedArrivalUnix != nil
        let tripScheduledArrivalIsInThePast = $0.scheduledArrivalUnix ?? 0 <= Int(Date().timeIntervalSince1970)
        let tripHasEstimatedArrival = $0.estimatedArrivalUnix != nil
        let tripEstimatedArrivalIsInThePast = $0.estimatedArrivalUnix ?? 0 <= Int(Date().timeIntervalSince1970)
        
        
        if tripScheduledArrivalIsInThePast {
            return false
        }
        
        if tripHasEstimatedArrival && tripEstimatedArrivalIsInThePast {
            return false
        }
        
        if tripHasObservedArrival {
            return false
        }
        
        return true
    })
    
    print("Filtered \(currentAndFutureFiltering.count) ETAs as currentAndFuture.")
    
    let sorted = currentAndFutureFiltering.sorted { (a, b) -> Bool in
        if let estimatedArrivalA = a.estimatedArrivalUnix, let estimatedArrivalB = b.estimatedArrivalUnix {
            // Both have estimated_arrival, compare them
            return estimatedArrivalA < estimatedArrivalB
        } else if a.estimatedArrivalUnix != nil {
            // Only `a` has estimated_arrival, so it comes before `b`
            return true
        } else if b.estimatedArrivalUnix != nil {
            // Only `b` has estimated_arrival, so it comes before `a`
            return false
        } else {
            // Both have only scheduled_arrival, compare them
            return a.scheduledArrivalUnix! < b.scheduledArrivalUnix!
        }
    }
    
    return sorted
}

func arrangeByStopIds(_ patternEtas: [PatternRealtimeETA]) -> [String: [PatternRealtimeETA]] {
    var arrangedDict = [String: [PatternRealtimeETA]]()
    
    for eta in patternEtas {
        if arrangedDict[eta.stopId] != nil {
            arrangedDict[eta.stopId]?.append(eta)
        } else {
            arrangedDict[eta.stopId] = [eta]
        }
    }
    
    return arrangedDict
}


func getRoundedMinuteDifferenceFromNow(_ refTimestamp: Int) -> Int {
    let now = Int(Date().timeIntervalSince1970)
    print("Rounded minute: NOW -> \(now); refTS -> \(refTimestamp)")
    let differenceInSeconds = now - refTimestamp
    let differenceInMinutes = differenceInSeconds / 60
    print("Minute difference is: \(differenceInMinutes)")
    return Int(differenceInMinutes.magnitude)
}
