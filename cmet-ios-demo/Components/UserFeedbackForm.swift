//
//  UserFeedbackForm.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 29/06/2024.
//

import SwiftUI

//enum QuestionType<T> {
enum QuestionType: Equatable {
    case yesOrNo, value, select(entries: [String])
}

//struct Question<T> {
struct Question {
    let text: String
    let type: QuestionType
    let onAction: (_ value: Any) -> Void
//    <T>
}


struct UserFeedbackForm: View {
    let title: String
    let description: String
    let questions: [Question]
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(title)
                        .font(.title3)
                        .bold()
                    Text(description)
                        .font(.callout)
                }
                .foregroundStyle(.white)
                Spacer()
            }
            .padding(.top, 5.0)
            .padding(.bottom, 20.0)
            
            ForEach(questions.indices, id: \.hashValue) { questionIndex in
                let question = questions[questionIndex]
                
                VStack {
                    HStack {
                        Text(question.text)
                            .bold()
                            .foregroundStyle(.white)
                        Spacer()
                        
                        if (question.type == .yesOrNo) {
                            yesNoButton(yes: true, onClick: {question.onAction(true)})
                            yesNoButton(yes: false, onClick: {question.onAction(false)})
                        }
                    }
                    .padding(.vertical, 5.0)
                    
                    if (questionIndex != questions.count - 1) {
                        Divider()
                            .frame(minHeight: 1.5)
                            .overlay(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding()
        .background(.cmFormBackground)
    }
    
    func yesNoButton(yes: Bool, onClick: @escaping () -> Void) -> some View {
        Button {
            onClick()
        } label: {
            HStack {
                Image(systemName: yes ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                Text(yes ? "Sim" : "Não")
                    .bold()
            }
            .foregroundStyle(yes ? .green : .red)
            .padding(10.0)
            .background(RoundedRectangle(cornerRadius: 5.0).fill(.white))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UserFeedbackForm(
        title: "Estas informações estão corretas?",
        description: "Ajude-nos a melhorar os transportes para todos.",
        questions: [
            Question(text: "Percursos e Paragens", type: .yesOrNo, onAction: {value in print("User responded with value \(value) to question Percursos e Paragens")}),
            Question(text: "Estimativas de Chegada", type: .yesOrNo, onAction: {value in print("User responded with value \(value) to question Estimativas de Chegada")}),
            Question(text: "Informações no Veículo", type: .yesOrNo, onAction: {value in print("User responded with value \(value) to question Informações no Veículo")})
        ]
    )
}
