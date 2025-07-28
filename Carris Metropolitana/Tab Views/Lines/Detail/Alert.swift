//
//  Alert.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 27/03/2024.
//

import SwiftUI

struct CMAlert: View {
    let alert: GtfsRtAlert
    
    @State private var imageViewerPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: getSystemIconForAlertEffect(alert.effect))
                Text(getTextForAlertEffect(alert.effect))
                    .bold()
                    .font(.title3)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 15.0)
            
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20.0, topTrailing: 20.0)).fill(.black))
            VStack {
                HStack {
                    Text(alert.headerText.translation[0].text)
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding(.vertical)
                Text(alert.descriptionText.translation[0].text)
                
                HStack {
                    if let image = alert.image, let imageUrl = URL(string: image.localizedImage[0].url) {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Color.clear
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        .frame(width: 128, height: 80)
                        .onTapGesture {
                            imageViewerPresented = true
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    if let start = alert.activePeriod[0].start {
                        (
                            Text("INÍCIO: ").foregroundStyle(.secondary) +
                            Text(getFormattedDateFromUnixTimestamp(TimeInterval(start)).uppercased()).foregroundStyle(.primary)
                        )
                        .font(.caption)
                        .bold()
                    }
                    Spacer()
                    if let end = alert.activePeriod[0].end {
                        (
                            Text("FIM: ").foregroundStyle(.secondary) +
                            Text(getFormattedDateFromUnixTimestamp(TimeInterval(end)).uppercased()).foregroundStyle(.primary)
                        )
                        .font(.caption)
                        .bold()
                    }
                }
                .padding(.vertical, 10.0)
                .padding(.bottom, 5.0)
            }
            .padding(.horizontal)
        }
        .background {
            RoundedRectangle(cornerRadius: 20.0)
                .stroke(.black, lineWidth: 5.0)
        }
        .sheet(isPresented: $imageViewerPresented) {
            if let image = alert.image, let imageUrl = URL(string: image.localizedImage[0].url) {
                let imageAttachment = MediaAttachment(
                    id: imageUrl.relativePath,
                    type: "image",
                    url: imageUrl,
                    previewUrl: nil,
                    description: nil,
                    meta: nil)
                MediaUIView(selectedAttachment: imageAttachment, attachments: [imageAttachment])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    
    func getSystemIconForAlertEffect(_ alertEffect: GtfsRtAlert.Effect) -> String {
        switch alertEffect {
        case .noService:
            return "xmark.circle"
        case .reducedService:
            return "minus.circle"
        case .significantDelays:
            return "clock.badge.exclamationmark"
        case .detour:
            return "arrow.triangle.swap"
        case .additionalService:
            return "plus.circle"
        case .modifiedService:
//            return "calendar.badge.exclamationmark"
            return "arrow.left.arrow.right"
        case .otherEffect:
            return "exclamationmark.triangle"
        case .unknownEffect:
            return "questionmark.diamond"
        case .stopMoved:
            return "arrow.triangle.branch"
        case .noEffect:
            return "checkmark.circle"
        case .accessibilityIssue:
            return "figure.roll"
        }
    }
    
    func getTextForAlertEffect(_ alertEffect: GtfsRtAlert.Effect) -> String {
        switch alertEffect {
        case .noService:
            return "Serviço Impedido"
        case .reducedService:
            return "Serviço Reduzido"
        case .significantDelays:
            return "Atrasos Significativos"
        case .detour:
            return "Desvio"
        case .additionalService:
            return "Aumento de Serviço"
        case .modifiedService:
//            return "calendar.badge.exclamationmark"
            return "Alteração de Serviço"
        case .otherEffect:
            return "Outros"
        case .unknownEffect:
            return "Desconhecido"
        case .stopMoved:
            return "Mudança de Paragem"
        case .noEffect:
            return "Serviço Normal"
        case .accessibilityIssue:
            return "Problema de Acessibilidade"
        }
    }
}

func getFormattedDateFromUnixTimestamp(_ timestamp: TimeInterval) -> String {
    
    let date = Date(timeIntervalSince1970: timestamp)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    
    let formattedDate = dateFormatter.string(from: date)
    
    return formattedDate
}

#Preview {
    CMAlert(
            alert: .init(
                alertId: "1234",
                activePeriod: [],
                cause: .strike,
                descriptionText: .init(
                    translation: [.init(
                        text: "Na noite de 24 para 25 de abril, entre as 20h00 e as 02h30, as linhas 3009, 3012, 3014 e 3708 terão desvios de trânsito devido às celebrações do 25 de abril na Praça S. João Batista e na Praça da Liberdade, em Almada. No sentido Cacilhas, o percurso alternativo será feito pela Rua Mendo Gomes de Seabra, Rua Capitão Leitão, Rua da Sociedade Filarmónica Incrível Almadense e Rua Bernardo Francisco da Costa. Com partida de Cacilhas, o percurso será realizado pela Rua Fernão Lopes, Avenida Dom João I e Rua Mendo Gomes de Seabra.",
                        language: "pt"
                    )]
                ),
                effect: .modifiedService,
                headerText: .init(
                    translation: [.init(
                        text: "Almada | 3009, 3012, 3014 e 3708: Condicionamento de trânsito Comemoração 25 de abril",
                        language: "pt"
                    )]
                ),
                informedEntity: [.init(
                    agencyId: "1",
                    routeId: "1523",
                    routeType: 2,
                    directionId: 3,
                    stopId: "2121"
                )],
                url: .init(
                    translation: [.init(
                        text: "blabla",
                        language: "ptpt"
                    )]
                ), image: .init(localizedImage: [.init(url: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/06/XI-Triatlo-Jovem-de-Amora.png", mediaType: "", language: "")])
            )
    )
    .padding()
}

