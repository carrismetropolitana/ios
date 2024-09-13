//
//  CMWModels.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 13/09/2024.
//

import Foundation

struct StartupMessage: Codable {
    let maxBuild: Int
    let minBuild: Int
    let presentationType: PresentationType
    let url: String
    
    enum PresentationType: String, Codable {
        case breaking, changelog
    }
}
