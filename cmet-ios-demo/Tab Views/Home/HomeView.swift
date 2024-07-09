//
//  HomeView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI

struct HomeView: View {
//    @State var isEasterEggVisible = false
    @AppStorage("____dev_isLoggedIn") var ____dev_isLoggedIn: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(.cmLogoWhite)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
//                        .onLongPressGesture(minimumDuration: 2) {
//                            isEasterEggVisible.toggle()
//                        }
                        .accessibilityLabel(Text("Logótipo da Carris Metropolitana"))
                    Spacer()
//                    WifiConnectButton()
                }
                .padding()
            }
            .background(.cmYellow)
            
            if (____dev_isLoggedIn) {
                PersonalUserView()
            } else {
                UnregisteredUserView()
            }
            
        }
//        .sheet(isPresented: $isEasterEggVisible) {
//            EasterEggView()
//        }
    }
}

struct WifiConnectButton: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(.windowBackground)
            HStack {
                Circle()
                    .overlay {
                        Image(systemName: "wifi")
                            .foregroundStyle(.windowBackground)
                    }
                    .padding(.vertical, 5)
                    .padding(.leading, 5)
                Spacer()
                Text("Ligar ao Wi-Fi")
                    .bold()
                    .lineLimit(1)
            }
            .padding(.trailing)
        }
        .frame(width: 180, height: 50)
    }
}

#Preview {
    HomeView()
}
