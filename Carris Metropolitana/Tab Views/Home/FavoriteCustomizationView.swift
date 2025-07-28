//
//  FavoriteCustomizationView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 20/03/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import SwiftUI

enum CustomizationViewType {
    case stop, line
}

struct FavoriteCustomizationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stopsManager: StopsManager
    @EnvironmentObject var linesManager: LinesManager
    @EnvironmentObject var favoritesManager: FavoritesManager

    let type: CustomizationViewType

    @State private var selectedStopId: String?
    @State private var selectedLineId: String?
    @State private var selectedPatternIds: [String] = []
    @State private var patternsForSelectedItem: [CMPattern] = []
    @State private var sendNotifications = true
    @State private var isErrorBannerPresented = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""

    var overrideItemId: String?
    var overrideFavoriteItem: FavoriteItem?
    @Binding var isSelfPresented: Bool

    var body: some View {
        List {
            selectionSection
            patternSection
            notificationsSection
            saveDeleteButtons
        }
        .navigationTitle(title)
        .onAppear(perform: loadInitialState)
        .onChange(of: selectedStopId) { fetchPatternsForStop() }
        .onChange(of: selectedLineId) { fetchPatternsForLine() }
        .onChange(of: selectedPatternIds) { print("selected: \(selectedPatternIds)") }
        .errorBanner(isPresented: $isErrorBannerPresented, title: $errorTitle, message: $errorMessage)
    }

    private var title: String {
        type == .stop ? "Paragem favorita" : "Linha favorita"
    }

    private var selectionSection: some View {
        Section {
            NavigationLink(destination: type == .stop
                           ? AnyView(SelectFavoriteStopView(selectedStopId: $selectedStopId))
                           : AnyView(SelectFavoriteLineView(selectedLineId: $selectedLineId))) {
                SelectedItemSummaryView(
                    type: type,
                    stopId: selectedStopId ?? overrideFavoriteItem?.stopId ?? overrideItemId,
                    lineId: selectedLineId ?? overrideFavoriteItem?.lineId ?? overrideItemId,
                    stops: stopsManager.stops,
                    lines: linesManager.lines
                )
            }
        } header: {
            HeaderView(
                title: "Selecionar \(type == .stop ? "paragem" : "linha")",
                subtitle: "Escolha uma \(type == .stop ? "paragem" : "linha") para visualizar na página principal."
            )
        }
    }

    private var patternSection: some View {
        Section {
            if patternsForSelectedItem.isEmpty {
                Text("Selecione uma \(type == .stop ? "paragem" : "linha")").foregroundStyle(.tertiary)
            } else {
                ForEach(patternsForSelectedItem) { pattern in
                    Button {
                        withAnimation(.snappy(duration: 0.3)) {
                            togglePatternSelection(pattern.id)
                        }
                    } label: {
                        SelectablePatternEntry(isSelected: selectedPatternIds.contains(pattern.id), pattern: pattern)
                    }
                    .tint(.listPrimary)
                }
            }
        } header: {
            HeaderView(
                title: "Selecionar destinos",
                subtitle: type == .stop ? "Escolha quais destinos pretende visualizar." : "Escolha 1 destino para gravar na página de entrada."
            )
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Receber notificações", isOn: $sendNotifications)
                .padding(.vertical, 5)
        } header: {
            HeaderView(
                title: "Ativar notificações",
                subtitle: "Receber notificações sempre que houver novos avisos para as linhas e paragens selecionadas."
            )
        }
    }

    private var saveDeleteButtons: some View {
        Section(footer:
            VStack(spacing: 20) {
                Button { save() } label: {
                    Text("Guardar")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(5.0)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button { save() } label: {
                    Text("Eliminar")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(5.0)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.top)
        ) { EmptyView() }
    }

    private func togglePatternSelection(_ id: String) {
        switch type {
        case .stop:
            selectedPatternIds.togglePresence(of: id)
        case .line:
            selectedPatternIds = [id]
        }
    }

    private func save() {
        guard !selectedPatternIds.isEmpty else {
            errorTitle = "Selecione \(type == .stop ? "pelo menos um destino" : "um destino")"
            isErrorBannerPresented = true
            return
        }

        let id = selectedStopId ?? overrideFavoriteItem?.stopId ?? overrideItemId
        let lineId = selectedLineId ?? overrideFavoriteItem?.lineId ?? overrideItemId

        let item = FavoriteItem(
            type: type == .stop ? .stop : .pattern,
            patternIds: selectedPatternIds,
            stopId: type == .stop ? id : nil,
            displayName: type == .line ? "\(lineId ?? "") - \(patternsForSelectedItem.first { $0.id == selectedPatternIds[0] }?.headsign ?? "")" : nil, lineId: type == .line ? lineId : nil,
            receiveNotifications: sendNotifications
        )

        favoritesManager.addFavorite(item)
        isSelfPresented.toggle()
    }

    private func delete() {
        if let fav = overrideFavoriteItem {
            favoritesManager.removeFavorite(fav)
        } else if let itemId = overrideItemId {
            favoritesManager.fuzzyRemove(itemId: itemId, itemType: type == .stop ? .stop : .pattern)
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func loadInitialState() {
        if let fav = overrideFavoriteItem {
            sendNotifications = fav.receiveNotifications
            selectedPatternIds = fav.patternIds
            loadPatterns(for: fav)
        } else if let itemId = overrideItemId {
            if favoritesManager.isFavorited(itemId: itemId, itemType: type == .stop ? .stop : .pattern),
               let existing = favoritesManager.favorites.first(where: { $0.stopId == itemId || $0.lineId == itemId }) {
                sendNotifications = existing.receiveNotifications
                selectedPatternIds = existing.patternIds
            }
            loadPatterns(forItemId: itemId)
        }
    }

    private func fetchPatternsForStop() {
        guard let id = selectedStopId,
              let stop = stopsManager.stops.first(where: { $0.id == id }),
              let patternIds = stop.patterns else { return }

        Task {
            patternsForSelectedItem = await validPatterns(for: patternIds)
        }
    }

    private func fetchPatternsForLine() {
        guard let id = selectedLineId,
              let line = linesManager.lines.first(where: { $0.id == id }) else { return }

        Task {
            patternsForSelectedItem = await validPatterns(for: line.patternIds)
        }
    }

    private func loadPatterns(for fav: FavoriteItem) {
        let ids = fav.patternIds
        Task {
            patternsForSelectedItem = await validPatterns(for: ids)
        }
    }

    private func loadPatterns(forItemId id: String) {
        if type == .stop, let stop = stopsManager.stops.first(where: { $0.id == id }), let pids = stop.patterns {
            Task { patternsForSelectedItem = await validPatterns(for: pids) }
        } else if type == .line, let line = linesManager.lines.first(where: { $0.id == id }) {
            Task { patternsForSelectedItem = await validPatterns(for: line.patternIds) }
        }
    }

    private func validPatterns(for ids: [String]) async -> [CMPattern] {
        await withTaskGroup(of: CMPattern?.self) { group in
            for id in ids {
                group.addTask {
                    let versions = await CMAPI.shared.getPatternVersions(id)
                    return versions.first(where: { $0.isValidOnCurrentDate() })
                }
            }

            var results: [CMPattern] = []
            for await result in group {
                if let pattern = result {
                    results.append(pattern)
                }
            }
            return results
        }
    }
}

private struct HeaderView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline).bold()
            Text(subtitle)
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
    }
}

private struct SelectedItemSummaryView: View {
    let type: CustomizationViewType
    let stopId: String?
    let lineId: String?
    let stops: [Stop]
    let lines: [Line]

    var body: some View {
        if let stopId, let stop = stops.first(where: { $0.id == stopId }) {
            VStack(alignment: .leading) {
                Text(stop.name)
                Text(stop.locality == stop.municipalityName || stop.locality == nil
                     ? stop.municipalityName
                     : "\(stop.locality!), \(stop.municipalityName)")
                    .foregroundStyle(.secondary)
            }
        } else if let lineId, let line = lines.first(where: { $0.id == lineId }) {
            LineEntry(line: line)
        } else {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.gray)
                Text("Procurar \(type == .stop ? "paragem" : "linha")")
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 8)
        }
    }
}

struct SelectablePatternEntry: View {
    let isSelected: Bool
    let pattern: CMPattern

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Pill(text: pattern.shortName, color: .init(hex: pattern.color), textColor: .init(hex: pattern.textColor))
                    .padding(.horizontal, 5)
                Text(pattern.headsign)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }
            .frame(height: 40)
            .padding(.vertical, 5)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .green : .primary)
                .scaleEffect(1.2)
                .padding(.trailing, 4)
        }
    }
}

private extension Array where Element: Equatable {
    mutating func togglePresence(of element: Element) {
        if let idx = firstIndex(of: element) {
            remove(at: idx)
        } else {
            append(element)
        }
    }
}
