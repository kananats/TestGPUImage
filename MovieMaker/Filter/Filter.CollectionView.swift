//
//  Filter.CollectionView.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import CoreGraphics
import Result
import ReactiveSwift
import GPUImage

// MARK: Main
extension Filter {
    
    /// A `UIView` for selecting `Filter`
    final class CollectionView: UIView {
        
        /// A `Model` for this `UIViewController`
        private let model = Model()

        /// A `UICollectionView` for selecting `Filter`
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
        
        /// A `UICollectionViewFlowLayout` for `UICollectionView`
        private let layout = UICollectionViewFlowLayout()
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.addSubview(self.collectionView)

            self.bind(with: self.model)
        }()

        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = .clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Inheritance
extension Filter.CollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = self.makeLayout
        
        self.updateLayout()
    }
}

// MARK: Protocol
extension Filter.CollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.model.indexPath.value != indexPath else { return }
        
        self.model.indexPath.swap(indexPath)
    }
}

extension Filter.CollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Filter.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        
        cell.update(filter: Filter.all[indexPath.row])
        
        cell.reactive.isSelected <~ self.model.indexPath.map { $0 == indexPath }
        
        return cell
    }
}

// MARK: Internal
internal extension Filter.CollectionView {
    
    /// A `Signal<Filter, NoError>` as the binding source
    var filter: Signal<Filter, NoError> { return self.model.filter.signal }
    
    /// A `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientationBindingTarget: BindingTarget<ImageOrientation> {
        return self.model.orientation.bindingTarget
    }
}

// MARK: Private
private extension Filter.CollectionView {
    
    /// A `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in
            `self`.updateLayout(orientation: value)
        }
    }
    
    /// Bind with `Filter.CollectionView.Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.orientation <~ model.orientation

        return disposable
    }
    
    /// Update layout constraints
    func updateLayout() {
        self.collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// Update layout constraints to fit corresponding `ImageOrientation`
    func updateLayout(orientation: ImageOrientation) {

        // Change item size
        var itemSize = Filter.previewSize
        if orientation.isPortrait { itemSize.height += 5 }
        else { itemSize.width += 5 }
        self.layout.itemSize = itemSize
        
        // Change scroll direction
        var scrollDirection: UICollectionView.ScrollDirection = .vertical
        if orientation.isPortrait { scrollDirection = .horizontal  }
        self.layout.scrollDirection = scrollDirection
    }
}
