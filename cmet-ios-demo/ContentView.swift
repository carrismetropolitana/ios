//
//  ContentView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "person.crop.circle.fill")
                }
            
            LinesView()
                .tabItem {
                    Label("Linhas", systemImage: "arrow.triangle.swap")
                }
            
            StopsView()
                .tabItem {
                    Label("Paragens", systemImage: "map")
                }
            
            MoreView()
                .tabItem {
                    Label("Mais", systemImage: "ellipsis")
                }

        }
        .onAppear {
                    let appearance = UITabBarAppearance()
//                    appearance.configureWithOpaqueBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
                    appearance.stackedLayoutAppearance.normal.iconColor = .gray
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                    
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(.primary)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(.primary)]
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
    }
}

#Preview {
    ContentView()
}
