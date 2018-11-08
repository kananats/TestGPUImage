//
//  MovieMaker.Filter.CollectionView.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import CoreGraphics
import ReactiveSwift
import GPUImage

extension MovieMaker.Filter {
    
    /// `UIView` for selecting `Filter`
    final class CollectionView: UIView {
        
        /// `Delegate` for `Filter.CollectionView`
        public weak var delegate: Delegate?
        
        /// `Model` for this `UIViewController`
        let model = Model()

        /// `UICollectionView` for selecting `Filter`
        private lazy var collectionView: UICollectionView = {
            let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: self.layout)
            
            collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)

            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false

            return collectionView
        }()
        
        /// `UICollectionViewLayout` for `UICollectionView`
        private let layout = UICollectionViewFlowLayout()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = .clear
            
            self.createLayout()
            self.bind(self.model)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Public
extension MovieMaker.Filter.CollectionView {
    
    /// `CGSize` of the filter preview area
    static let filterSize = CGSize(width: 85, height: 60)
}

// Protocol
extension MovieMaker.Filter.CollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.model.indexPath.value != indexPath else { return }
        
        self.model.indexPath.swap(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var size = MovieMaker.Filter.CollectionView.filterSize
        
        if self.model.orientation.value.isPortrait { size.height += 5 }
        else { size.width += 5 }

        return size
    }
}

extension MovieMaker.Filter.CollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return MovieMaker.Filter.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        
        let filter = MovieMaker.Filter.all[indexPath.row]
        cell.update(name: filter.name, image: nil)
        
        cell.reactive.isSelected <~ self.model.indexPath.map { $0 == indexPath }

        return cell
    }
}

// Private
private extension MovieMaker.Filter.CollectionView {
    
    /// `BindingTarget<ImageOrientation>` for adaptive orientation
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in
            `self`.updateLayout(orientation: value)
        }
    }
    
    /// Bind with `Model`
    @discardableResult
    func bind(_ model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.orientation <~ model.orientation
        /*
         let filter = CameraFilterCollectionView.filters[indexPath.row]
         self.delegate?.filterDidSelect(filter)
         */

        return disposable
    }
    
    /// Layout initialization
    func createLayout() {
        self.addSubview(self.collectionView)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// Update constraints to fit new `ImageOrientation`
    func updateLayout(orientation: ImageOrientation) {
        
        // Change item size
        var itemSize = MovieMaker.Filter.CollectionView.filterSize
        if orientation.isPortrait { itemSize.height += 5 }
        else { itemSize.width += 5 }
        self.layout.itemSize = itemSize
        
        // Change scroll direction
        var scrollDirection: UICollectionView.ScrollDirection = .horizontal
        if orientation.isPortrait { scrollDirection = .vertical  }
        self.layout.scrollDirection = scrollDirection
    }
}
