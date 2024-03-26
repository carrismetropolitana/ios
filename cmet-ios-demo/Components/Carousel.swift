//
//  Carousel.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI

struct Carousel<Content: View,T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    
    init(spacing: CGFloat = 15,trailingSpace: CGFloat = 200,index: Binding<Int>,items: [T],@ViewBuilder content: @escaping (T)->Content){
        
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View{
        
        GeometryReader{proxy in
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustMentWidth = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing){
                ForEach(list){item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace, height: 100)
                }
            }
            .padding(.horizontal,spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustMentWidth : 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        .animation(.easeInOut, value: offset == 0)
    }
}

struct User: Identifiable{
    var id = UUID().uuidString
    var userName: String
    var userImage: String
}

struct ImagePage: Identifiable {
    var id = UUID().uuidString
    var imageUrl: URL
    var linkTo: URL
}

struct CarouselTestView: View {
    
    @State var currentIndex: Int = 0
    @State var images: [ImagePage] = []
    
    var body: some View {
        VStack() {
            Carousel(index: $currentIndex, items: images) {image in
                
                GeometryReader{proxy in
                    
                    let size = proxy.size
                    
                    AsyncImage(url: image.imageUrl)
                    { image in image.resizable() } placeholder: { Color.red } .frame(width: size.width) .clipShape(RoundedRectangle(cornerRadius: 25))
//                        .frame(width: size.width)
//                        .aspectRatio(contentMode: .fill)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: size.width)
//                        .cornerRadius(12)
                }
            }
            .padding(.vertical,40)
            
            // Indicator dots
            HStack(spacing: 10){
                
                ForEach(images.indices,id: \.self){index in
                    
                    Circle()
                        .fill(Color.black.opacity(currentIndex == index ? 1 : 0.1))
                        .frame(width: 10, height: 10)
                        .scaleEffect(currentIndex == index ? 1.4 : 1)
                        .animation(.spring(), value: currentIndex == index)
                }
            }
            .padding(.bottom,40)
        }
        .onAppear {
            for index in 1...5{
                images.append(ImagePage(imageUrl: URL(string: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/02/Artes-_-3028-Circular-Lazarim_Banner.png")!, linkTo: URL(string: "https://google.com/")!))
            }
        }
    }
}

//AsyncImage(url: URL(string: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/02/Artes-_-3028-Circular-Lazarim_Banner.png"), scale: 4)
//    .clipShape(RoundedRectangle(cornerRadius: 15))
//    .id(2)
//    .containerRelativeFrame(.horizontal)

#Preview {
    CarouselTestView()
}
