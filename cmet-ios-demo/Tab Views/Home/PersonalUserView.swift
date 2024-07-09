//
//  PersonalUserView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 20/03/2024.
//

import SwiftUI

struct PersonalUserView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @EnvironmentObject var stopsManager: StopsManager
    @EnvironmentObject var linesManager: LinesManager
    
    @State private var isSheetOpen = false
    @State private var isUserProfileSheetVisible = false
    var body: some View {
        ScrollView {
//            Button {
//                isUserProfileSheetVisible.toggle()
//            } label: {
//                HStack {
//                    Circle()
//                        .fill(.gray.secondary)
//                        .overlay {
//                            Image(systemName: "person.fill")
//                        }
//                        .frame(height: 40)
//                    Text("Olá André")
//                        .bold()
//                    Spacer()
//                }
//                .padding()
//            }
//            .buttonStyle(.plain)
            
            HStack {
                Text("Favoritos")
                    .bold()
                    .font(.title2)
                Spacer()
            }
            .padding()
            
            VStack (spacing: 20) {
                ForEach(favoritesManager.favorites) { fav in
//                    WidgetPlaceholder(text: fav.type == .pattern ? "WOULD SHOW WIDGET FOR PATTERN \(fav.patternIds[0])" : "WOULD SHOW WIDGET FOR STOP \(fav.stopId ?? "UNKNOWN"); PATTERNS \(fav.patternIds)")
                    if fav.type == .stop {
                        FavoriteStopWidgetView(stop: stopsManager.stops.first { $0.id == fav.stopId }, patternIds: fav.patternIds)
                    } else if fav.type == .pattern {
//                        let _ = print("Is pat w t: " + String(describing: fav))
//                        let _ = print("liat: " + String(linesManager.lines.count))
//                        NavigationLink(destination: LineDetailsView(
//                            line: linesManager.lines.first { $0.id == fav.lineId! }!,
//                            overrideDisplayedPatternId: fav.patternIds[0])) {
                            FavoriteLineWidgetView(patternId: fav.patternIds[0])
//                        }
                    }
                }
            }
            .padding(.horizontal)
            
//            Button {
//                isSheetOpen.toggle()
//            } label: {
//                HStack {
//                    Image(systemName: "square.and.pencil")
//                        .padding(.horizontal, 5)
//                    Text("Personalizar")
//                }
//                .padding(.vertical, 10)
//            }
//            .buttonStyle(StopOptionsButtonStyle())
//            
            
            Button {
                isSheetOpen.toggle()
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Personalizar")
                        .font(.title2)
                        .bold()
                }
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10.0)
            }
            .tint(.gray.opacity(0.3))
            .buttonStyle(.borderedProminent)
            .padding()
            
            
        }
        .contentMargins(.bottom, 20.0, for: .scrollContent)
//        .contentMargins(.top, 20.0, for: .scrollContent)
        .sheet(isPresented: $isSheetOpen) {
            CustomizeWidgetsSheetView(isSheetOpen: $isSheetOpen)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isUserProfileSheetVisible) {
            UserProfileSheetView()
                .presentationDragIndicator(.visible)
        }

    }
}

struct WidgetPlaceholder: View {
    var text: String? = nil
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .fill(.gray.tertiary)
            .frame(height: 200)
            .overlay {
                Text(text ?? "SEM WIDGET DEFINIDO")
                    .fontWeight(.heavy)
                    .foregroundStyle(.gray)
            }
    }
}

#Preview {
    PersonalUserView()
}
