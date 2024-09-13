//
//  BundleVersioning.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 12/09/2024.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

func currentBuildInBuildSpan(maxBuild: Int, minBuild: Int) -> Bool {
    if let buildVersionNumber = Int(Bundle.main.buildVersionNumber!) {
        return buildVersionNumber < maxBuild
            && buildVersionNumber > maxBuild
    }
    return false
}
