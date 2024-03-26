//
//  SmartNotificationWidgetView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 14/03/2024.
//

import SwiftUI

struct SmartNotificationSchedule {
    let weekdays: [Weekday]
    let startHour: DateComponents
    let endHour: DateComponents
}

struct SmartNotificationConfiguration {
    let line: Line // or route/pattern??
    let stop: Stop
    let schedule: SmartNotificationSchedule
    let conditionType: ConditionValueType
    let conditionValue: Int
}

struct SmartNotificationWidgetView: View {
//    let config: SmartNotificationConfiguration
    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .fill(.white)
            .frame(height: 200)
            .overlay {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Hospital (Elvas)")
                                .bold()
                            HStack {
                                Text("Cova da Piedade, Almada")
                                    .foregroundStyle(.secondary)
                                Text("020497")
                                    .font(.custom("Menlo", size: 12.0).monospacedDigit())
//                                    .font(.footnote)
                                    .bold()
                                    .foregroundStyle(.gray)
                                    .padding(.horizontal, 10)
                                    .background(Capsule().stroke(.gray, lineWidth: 2.0))
                            }
                        }
                        Spacer()
                        Image(systemName: "bell.badge")
                            .background {
                                Circle()
                                    .fill(.green)
//                                    .background {
//                                        Circle()
//                                            .fill(.black)
//                                            .padding()
//                                    }
                                    .padding()
                            }
                    }
                    .padding(10)
                    Divider()
                    
                    Spacer()
                }
            }
    }
}

#Preview {
    SmartNotificationWidgetView()
        .shadow(color: .gray.opacity(0.3), radius: 20)
        .padding()
}
