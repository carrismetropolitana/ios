//
//  SquaredButton.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 07/06/2024.
//

import SwiftUI

struct SquaredButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let action: () -> Void
    let systemIcon: String?
    let imageResourceIcon: ImageResource?
    let iconColor: Color
    let badgeValue: Int
    let size: CGFloat? = 60
    
    let badgeOffsetFactor = 2.3
    
    
    var body: some View {
        ZStack {
            Button {
                action()
            } label: {
                RoundedRectangle(cornerRadius: 15.0)
                    .fill(.windowBackground)
                    .overlay {
                        if let systemIcon = systemIcon {
                            Image(systemName: systemIcon)
                                .foregroundStyle(iconColor)
                                .font(.title)
                        } else {
                            Image(imageResourceIcon!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(iconColor)
                                .frame(width: 28.0)
                        }
                    }
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.1), radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .dark ? .gray.opacity(0.3) : .white, lineWidth: 2)
                    )
            }.buttonStyle(.plain)
            if badgeValue > 0 {
                Text("\(badgeValue)")
                    .padding(.horizontal, badgeValue > 9 ? 5.0 : 7.0)
                    .padding(.vertical, 1.0)
                    .foregroundStyle(.white)
                    .background() {
                        Capsule()
                            .fill(.red)
                    }
                    .offset(x:size!/badgeOffsetFactor, y:-size!/badgeOffsetFactor)
            }
        }
    }
}


#Preview {
    SquaredButton(action: {print("SquaredButton clicked!")}, systemIcon: "exclamationmark.triangle", imageResourceIcon: nil, iconColor: .black, badgeValue: 1)
}
