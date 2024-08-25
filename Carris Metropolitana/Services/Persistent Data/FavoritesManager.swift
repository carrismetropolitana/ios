//
//  FavoritesService.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 26/05/2024.
//

import Foundation
import FirebaseMessaging

enum FavoriteType: Codable {
    case pattern, stop
}

struct FavoriteItem: Codable, Identifiable {
    let id: String
    let type: FavoriteType
    let displayName: String?
    let lineId: String?
    let stopId: String?
    private(set) var patternIds: [String]
    
    init(type: FavoriteType, patternIds: [String], stopId: String? = nil, displayName: String? = nil, lineId: String? = nil) {  // if type == .pattern then patternId.count should equal 1; if for some god forsaken reason it isnt use first and ignore others (shouldn't happen but still)
        self.type = type
        self.displayName = displayName
        self.lineId = lineId
        self.stopId = stopId
        if type == .pattern {
            self.patternIds = patternIds.count > 0 ? [patternIds[0]] : []
            self.id = "favorites:pattern:\(patternIds[0])"
        } else {
            self.id = "favorites:stop:\(stopId!)"
            self.patternIds = patternIds
        }
    }
}


class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteItem] = []
    private let userDefaultsKey = "userFavorites"

    init() {
        loadFavorites()
    }
    
    func addFavorite(_ item: FavoriteItem) {
        if let index = favorites.firstIndex(where: { $0.id == item.id }) {
            favorites.remove(at: index)
            favorites.insert(item, at: index)
        } else {
            favorites.append(item)
        }
        saveFavorites()
    }
    
    func moveFavorites(fromOffsets: IndexSet, toOffset: Int) {
        favorites.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveFavorites()
    }
    
    func isFavorited(itemId: String, itemType: FavoriteType) -> Bool { // cant be checking for line ids, there can be many same lineids, with different patternids, or maybe not??
        return favorites.contains {
            itemId == (itemType == .stop ? $0.stopId : $0.lineId)
        }
    }
    
    func removeFavorite(_ item: FavoriteItem) {
        if let index = favorites.firstIndex(where: { $0.patternIds == item.patternIds && $0.type == item.type }) {
            favorites.remove(at: index)
            saveFavorites()
        }
    }
    
    func fuzzyRemove(itemId: String, itemType: FavoriteType) {
        if itemType == .stop {
            if let index = favorites.firstIndex(where: { $0.stopId == itemId }) {
                favorites.remove(at: index)
                saveFavorites()
            }
        } else if itemType == .pattern {
            if let index = favorites.firstIndex(where: { $0.lineId == itemId }) {
                favorites.remove(at: index)
                saveFavorites()
            }
        }
    }
    
    func wipeFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    private func saveFavorites() {
        let encoder = PropertyListEncoder()
        if let encoded = try? encoder.encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.data(forKey: userDefaultsKey) {
            let decoder = PropertyListDecoder()
            if let loadedFavorites = try? decoder.decode([FavoriteItem].self, from: savedFavorites) {
                favorites = loadedFavorites
            }
        }
    }
    
    
    func subscribeToFavorites() {
        // TODO: add sendNotifications property to favorites
//        for favorite in favorites {
//            if favorite.type == .pattern {
//                Messaging.messaging().subscribe(toTopic: "cm.realtime.alerts.route.\(favorite.)") { error in }
//            }
//        }
    }
}
