//
//  MovieMaker.Filter.CollectionView.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import CoreGraphics
import Result
import ReactiveSwift
import GPUImage

extension MovieMaker.Filter {
    
    /// `UIView` for selecting `Filter`
    final class CollectionView: UIView {
        
        /// `Model` for this `UIViewController`
        private let model = Model()

        /// `UICollectionView` for selecting `Filter`
        private lazy var collectionView: UICollectionView = {
            let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: self.layout)
            
            collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)

            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false

            return collectionView
        }()
        
        /// `UICollectionViewFlowLayout` for `UICollectionView`
        private let layout = UICollectionViewFlowLayout()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = .clear
            
            self.createLayout()
            self.bind(with: self.model)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Public
extension MovieMaker.Filter.CollectionView {
    
    /// `CGSize` of the `Filter` select view
    static let filterSize = CGSize(width: 85, height: 60)
    
    /// `Signal<Filter, NoError>` as the binding source
    var filter: Signal<MovieMaker.Filter, NoError> { return self.model.filter.signal }
    
    /// `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientationBindingTarget: BindingTarget<ImageOrientation> {
        return self.model.orientation.bindingTarget
    }
}

// Protocol
extension MovieMaker.Filter.CollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.model.indexPath.value != indexPath else { return }
        
        self.model.indexPath.swap(indexPath)
    }
}

extension MovieMaker.Filter.CollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MovieMaker.Filter.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        
        cell.update(filter: MovieMaker.Filter.all[indexPath.row])
        
        cell.reactive.isSelected <~ self.model.indexPath.map { $0 == indexPath }

        return cell
    }
}

// Private
private extension MovieMaker.Filter.CollectionView {
    
    /// `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in
            `self`.updateLayout(orientation: value)
        }
    }
    
    /// Bind with `Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.orientation <~ model.orientation

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
        var scrollDirection: UICollectionView.ScrollDirection = .vertical
        if orientation.isPortrait { scrollDirection = .horizontal  }
        self.layout.scrollDirection = scrollDirection
    }
}
