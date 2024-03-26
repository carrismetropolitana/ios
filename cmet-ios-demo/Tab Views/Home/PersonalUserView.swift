//
//  PersonalUserView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 20/03/2024.
//

import SwiftUI

struct PersonalUserView: View {
    @State private var isSheetOpen = false
    @State private var isUserProfileSheetVisible = false
    var body: some View {
        ScrollView {
            Button {
                isUserProfileSheetVisible.toggle()
            } label: {
                HStack {
                    Circle()
                        .fill(.gray.secondary)
                        .overlay {
                            Image(systemName: "person.fill")
                        }
                        .frame(height: 40)
                    Text("Olá André")
                        .bold()
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            VStack (spacing: 20) {
                WidgetPlaceholder()
                WidgetPlaceholder()
                WidgetPlaceholder()
            }
            .padding(.horizontal)
            
            Button {
                isSheetOpen.toggle()
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .padding(.horizontal, 5)
                    Text("Personalizar")
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(StopOptionsButtonStyle())
        }
        .contentMargins(.bottom, 20.0, for: .scrollContent)
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
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .fill(.gray.tertiary)
            .frame(height: 200)
            .overlay {
                Text("SEM WIDGET DEFINIDO")
                    .fontWeight(.heavy)
                    .foregroundStyle(.gray)
            }
    }
}

#Preview {
    PersonalUserView()
}
