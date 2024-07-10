//
//  CMLogoAnimation.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 09/07/2024.
//

import SwiftUI
import Lottie

struct CMLogoAnimation: View {
    var body: some View {
        VStack {
            LottieView(animation: .named("CMLogoLoop"))
                .animationSpeed(1.5)
                .playing(loopMode: .autoReverse)
                .frame(width: 250)
        }
    }
}

#Preview {
    CMLogoAnimation()
}
