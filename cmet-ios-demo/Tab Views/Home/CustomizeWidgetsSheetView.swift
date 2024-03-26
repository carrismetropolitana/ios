//
//  CustomizeWidgetsSheetView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 20/03/2024.
//

import SwiftUI

enum WidgetType: String {
    case favoriteStop = "Paragem Favorita"
    case favoriteLine = "Linha Favorita"
    case smartNotification = "Notificação Inteligente"
}

struct Widget {
    let name: String
    let type: WidgetType
    let defaultValue: String
    let systemImage: String
    let color: Color
}

let staticWidgets = [
    Widget(name: WidgetType.favoriteStop.rawValue, type: .favoriteStop, defaultValue: "Hospital (Elvas)", systemImage: "mappin.and.ellipse", color: .orange),
    Widget(name: WidgetType.favoriteLine.rawValue, type: .favoriteLine, defaultValue: "3025 - Pragal (Estação)", systemImage: "arrow.triangle.swap", color: .red),
    Widget(name: WidgetType.smartNotification.rawValue, type: .smartNotification, defaultValue: "Hospital (Elvas)", systemImage: "bell.badge", color: .green)
]

struct CustomizeWidgetsSheetView: View {
    @Binding var isSheetOpen: Bool
    
    @State var editMode: EditMode = .active
    @State var widgets = [ // TODO: here temporarily as mock values, this should be coherent with the home page widgets
        Widget(name: WidgetType.favoriteStop.rawValue, type: .favoriteStop, defaultValue: "Hospital (Elvas)", systemImage: "mappin.and.ellipse", color: .orange),
        Widget(name: WidgetType.favoriteLine.rawValue, type: .favoriteLine, defaultValue: "3025 - Pragal (Estação)", systemImage: "arrow.triangle.swap", color: .red),
        Widget(name: WidgetType.smartNotification.rawValue, type: .smartNotification, defaultValue: "Hospital (Elvas)", systemImage: "bell.badge", color: .green)
    ]
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        ForEach(widgets, id: \.self.type) { widget in
                            NavigationLink(destination: SmartNotificationCustomizationView()) {
                                HStack {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.title2)
                                        .foregroundStyle(.tertiary)
                                        .padding(.trailing, 10)
                                    VStack(alignment: .leading) {
                                        Text(widget.name)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                        Text(widget.defaultValue)
                                            .bold()
                                    }
                                }
                            }
                        }
                        .onMove(perform: { indices, newOffset in
                            widgets.move(fromOffsets: indices, toOffset: newOffset)
                        })
                    } header: {
                        VStack(alignment: .leading) {
                            Text("Ordenar Cartões")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.primary)
                            Text("Organize os cartões como quer que apareçam na página principal. Altere a ordem deslizando no ícone \(Image(systemName: "line.3.horizontal"))") // wow i had no idea, cool, actually makes so much sense since SF Symbols conform to a common thing with Text
                        }
                        .textCase(nil)
                        .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
                    }
                    
                    Section {
                        ForEach(staticWidgets, id: \.self.type) { widget in
                            HStack {
                                Image(systemName: widget.systemImage)
                                    .font(.title2)
                                    .foregroundStyle(widget.color)
                                    .padding(.trailing, 10)
                                Text(widget.name)
                                    .bold()
                                    .padding(.vertical, 8)
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.green)
                            }
                            .background(NavigationLink("", destination: getDestinationForNewWidgetLink(widget: widget)))
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            Text("Adicionar novo cartão")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.primary)
                            Text("Escolha um tipo de cartão para adicionar à página principal.")
                        }
                        .textCase(nil)
                        .listRowInsets(EdgeInsets(top: 40, leading: 0, bottom: 10, trailing: -8)) // wooow also new for me very kewl
                    }
                }
            }
            .navigationTitle("Personalizar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSheetOpen.toggle()
                    } label: {
                        Text("Fechar")
                    }
                }
            }
        }
//        .environment(\.editMode, $editMode)
    }
}

func getDestinationForNewWidgetLink(widget: Widget) -> some View {
    switch widget.type {
    case .favoriteStop:
        return AnyView(Text("New FavoriteStop Widget"))
    case .favoriteLine:
        return AnyView(Text("New FavoriteLine Widget"))
    case .smartNotification:
        return AnyView(SmartNotificationCustomizationView())
    }
}



extension View {
    func scrollEnabled(_ value: Bool) -> some View {
        self.onAppear {
            UITableView.appearance().isScrollEnabled = value // will probably affect other scrollviews in scope (?)
        }
    }
}

//#Preview {
//    CustomizeWidgetsSheetView(isSheetOpen: false)
//}
