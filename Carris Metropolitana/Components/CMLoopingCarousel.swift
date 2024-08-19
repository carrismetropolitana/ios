//
//  CMLoopingCarousel.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 20/06/2024.
//

import SwiftUI

import SwiftUI
import UIKit

enum ContentType {
    case news, alert
}

struct CarouselItem {
    let contentId: Int
    let contentType: ContentType
    let imageURL: URL
}

struct LoopingCarousel: UIViewRepresentable {
    var items: [CarouselItem]
    let onItemClick: (_ item: CarouselItem) -> Void
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "Cell")
        
        context.coordinator.startAutoScroll(collectionView: collectionView)
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        var parent: LoopingCarousel
        var timer: Timer?
        var isUserScrolling = false
        
        init(_ parent: LoopingCarousel) {
            self.parent = parent
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1000 // large number to simulate infinite scrolling
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return parent.items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CarouselCell
            let index = indexPath.item % parent.items.count
            let item = parent.items[index]
            cell.configure(with: item)
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: UIScreen.main.bounds.width, height: 200)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let index = indexPath.item % parent.items.count
            let item = parent.items[index]
            parent.onItemClick(item)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isUserScrolling = true
            stopAutoScroll()
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            isUserScrolling = false
            startAutoScroll(collectionView: scrollView as! UICollectionView)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if !scrollView.isTracking {
                handleAutoScrollEnd(collectionView: scrollView as! UICollectionView)
            }
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            handleAutoScrollEnd(collectionView: scrollView as! UICollectionView)
        }
        
        func startAutoScroll(collectionView: UICollectionView) {
            stopAutoScroll()
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                guard let self = self, !self.isUserScrolling else { return }
                let nextIndexPath = self.getNextIndexPath(for: collectionView)
                collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
        
        func stopAutoScroll() {
            timer?.invalidate()
            timer = nil
        }
        
        func handleAutoScrollEnd(collectionView: UICollectionView) {
            guard !isUserScrolling else { return }
            let currentOffset = collectionView.contentOffset.x
            let contentWidth = collectionView.contentSize.width
            let pageWidth = collectionView.frame.size.width
            
            if currentOffset <= 0 {
                collectionView.contentOffset = CGPoint(x: contentWidth - 2 * pageWidth, y: 0)
            } else if currentOffset >= contentWidth - pageWidth {
                collectionView.contentOffset = CGPoint(x: pageWidth, y: 0)
            }
            
            startAutoScroll(collectionView: collectionView)
        }
        
        func getNextIndexPath(for collectionView: UICollectionView) -> IndexPath {
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
            guard let currentIndexPath = visibleIndexPaths.first else { return IndexPath(item: 0, section: 0) }
            let nextItem = (currentIndexPath.item + 1) % parent.items.count
            let nextSection = currentIndexPath.section + (nextItem == 0 ? 1 : 0)
            return IndexPath(item: nextItem, section: nextSection)
        }
    }
}


class CarouselCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15.0
        imageView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(with item: CarouselItem) {
        loadImage(from: item.imageURL)
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
}

struct CMLCContentView: View {
    let dummyItems = [
        CarouselItem(contentId: 0, contentType: .news, imageURL: URL(string: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/06/AF-Inquerito-Noticia-_-Banner.png")!),
        CarouselItem(contentId: 1, contentType: .news, imageURL: URL(string: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/06/Linhas-Mar_Banner.png")!),
        CarouselItem(contentId: 2, contentType: .news, imageURL: URL(string: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/05/AF-_-Santo-Antonio_Banner-1.png")!),
        CarouselItem(contentId: 3, contentType: .news, imageURL: URL(string: "https://www.carrismetropolitana.pt/wp-content/uploads/2024/05/Banner-Mini-Passageiros.png")!)
    ]
    
    var body: some View {
        LoopingCarousel(items: dummyItems, onItemClick: { item in })
            .frame(height: 200)
    }
}

#Preview {
    CMLCContentView()
}
