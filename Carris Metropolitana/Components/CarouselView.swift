//
//  LoopingScrollView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 13/03/2024.
//

import SwiftUI

struct Page: Identifiable, Equatable {
    var id: UUID = UUID()
    let color: Color
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offsetX(_ addObserver: Bool, completion: @escaping (CGRect) -> ()) -> some View {
        self
            .frame(maxWidth: .infinity)
            .overlay {
                if addObserver {
                    GeometryReader {
                        let rect = $0.frame(in: .global)
                        
                        Color.clear.preference(key: OffsetKey.self, value: rect)
                            .onPreferenceChange(OffsetKey.self, perform: completion)
                    }
                }
            }
    }
}

struct PageControl: UIViewRepresentable {
    var totalPages: Int
    var currentPage: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = totalPages
        control.currentPage = currentPage
        control.backgroundStyle = .prominent
        control.allowsContinuousInteraction = false
        
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = totalPages
        uiView.currentPage = currentPage
    }
}

struct CarouselView: View {
    @State private var currentPage = ""
    @State private var listOfPages: [Page] = []
    @State private var fakedPages: [Page] = []
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(fakedPages) { page in
                        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                            .fill(page.color)
                            .frame(width: 300, height: geo.size.height)
                            .tag(page.id.uuidString)
                            .offsetX(currentPage == page.id.uuidString) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (geo.size.width * CGFloat(fakeIndex(page)))
                                
                                let pageProgress = pageOffset / geo.size.width
                                
                                if -pageProgress < 1.0 {
                                    if fakedPages.indices.contains(fakedPages.count - 1 ) {
                                        currentPage = fakedPages[fakedPages.count - 1].id.uuidString
                                    }
                                }
                                
                                if -pageProgress > CGFloat(fakedPages.count - 1) {
                                    if fakedPages.indices.contains(1) {
                                        currentPage = fakedPages[1].id.uuidString
                                    }
                                }
                            }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                PageControl(totalPages: listOfPages.count, currentPage: originalIndex(currentPage))
                    .offset(y: -15)
            }
        }
        .onAppear {
            guard fakedPages.isEmpty else { return }
            for color in [Color.red, Color.blue, Color.yellow, Color.black, Color.brown] {
                listOfPages.append(.init(color: color))
            }
            
            fakedPages.append(contentsOf: listOfPages)
            
            if var firstPage = listOfPages.first, var lastPage = listOfPages.last {
                currentPage = firstPage.id.uuidString
                
                firstPage.id = .init()
                lastPage.id = .init()
                
                fakedPages.append(firstPage)
                fakedPages.insert(lastPage, at: 0)
            }
        }
    }
    
    func fakeIndex(_ of: Page) -> Int {
        return fakedPages.firstIndex(of: of) ?? 0
    }
    
    func originalIndex(_ id: String) -> Int {
        return listOfPages.firstIndex { page in
            page.id.uuidString == id
        } ?? 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView()
            .frame(height: 300)
    }
}
