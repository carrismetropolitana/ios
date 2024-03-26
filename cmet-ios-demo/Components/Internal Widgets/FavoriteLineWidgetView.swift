//
//  FavoriteLineWidgetView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 14/03/2024.
//

import SwiftUI

struct FavoriteLineWidgetView: View {
    @State private var _______tempForUiDemoPurposes_isFavorited = false
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Hospital (Elvas)")
                        .font(.headline)
                    Text("Cova da Piedade, Almada")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .bold()
                }
                Spacer()
                Button {
                    _______tempForUiDemoPurposes_isFavorited.toggle()
                } label: {
                    Image(systemName: _______tempForUiDemoPurposes_isFavorited ? "star.fill" : "star")
                        .font(.title2)
                    .foregroundStyle(.yellow)
                }
            }
            .padding(.top, 15.0)
            .padding(.horizontal, 15.0)
            
            Divider()
                .frame(minHeight: 3.0)
                .overlay(.gray.opacity(0.1))
            
            HStack {
                Pill(text: "2042", color: Color(hex: "C61D23"), textColor: .white, size: 60)
                Image(systemName: "arrow.right")
                Text("Alfornelos")
                    .font(.title3)
                    .bold()
                Spacer()
            }
            .padding(10.0)
            
        }
        .background(RoundedRectangle(cornerRadius: 15.0).fill(.white))
    }
}



#Preview {
    FavoriteLineWidgetView()
        .shadow(color: .gray.opacity(0.3), radius: 20)
        .padding()
}
