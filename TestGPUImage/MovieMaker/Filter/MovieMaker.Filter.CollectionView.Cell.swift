//
//  MovieMaker.Filter.CollectionView.Cell.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import GPUImage

extension MovieMaker.Filter.CollectionView {
    
    /// `Cell` used in `Filter.CollectionView`
    final class Cell: UICollectionViewCell {

        /// `UIView` indicating whether this `Cell` is being selected
        fileprivate lazy var indicator: UIView = {
            let indicator = UIView()
            indicator.backgroundColor = .purple
            return indicator
        }()
        
        /// `UIImageView` showing filter sample
        lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            return imageView
        }()
        
        /// `UILabel` showing filter name
        lazy var label: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 10)
            label.textColor = .white
            label.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            return label
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)

            self.createLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Public
extension MovieMaker.Filter.CollectionView.Cell {
    
    /// `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(value) }
    }
    
    // todo
    /// Update `Cell` information using `Filter`
    func update(name: String, image: UIImage?) {
        self.label.text = name
        self.imageView.image = image
    }
}

// Protocol
extension MovieMaker.Filter.CollectionView.Cell: Reusable {
    static let reuseIdentifier = "MovieMakerFilterCollectionViewCell"
}

// Private
private extension MovieMaker.Filter.CollectionView.Cell {
    
    /// Layout initialization
    func createLayout() {
        self.contentView.addSubview(self.indicator)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.label)
        
        self.updateLayout(.portrait)
    }
    
    /// Update constraints to fit new orientation
    func updateLayout(_ orientation: ImageOrientation) {
        if orientation.isPortrait { self.updatePortraitLayout() }
        else { self.updateLandscapeLayout() }
        
        self.label.snp.remakeConstraints { make in
            make.left.equalTo(self.imageView).offset(2)
            make.bottom.equalTo(self.imageView).offset(-2)
        }
    }
    
    /// Portrait constraits
    func updatePortraitLayout() {
        self.indicator.snp.remakeConstraints { make in
            make.width.equalTo(3)
            make.height.equalTo(MovieMaker.Filter.CollectionView.filterSize.height)
            make.left.equalTo(self)
            make.centerY.equalTo(self)
        }
        
        self.imageView.snp.remakeConstraints { make in
            make.size.equalTo(MovieMaker.Filter.CollectionView.filterSize)
            make.left.equalTo(self.indicator.snp.right).offset(2)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    /// Landscape constraits
    func updateLandscapeLayout() {
        self.indicator.snp.remakeConstraints { make in
            make.width.equalTo(MovieMaker.Filter.CollectionView.filterSize.width)
            make.height.equalTo(3)
            make.centerX.equalTo(self)
            make.top.equalTo(self)
        }
        
        self.imageView.snp.remakeConstraints { make in
            make.size.equalTo(MovieMaker.Filter.CollectionView.filterSize)
            make.top.equalTo(self.snp.bottom).offset(2)
            make.centerX.equalTo(self.contentView)
        }
    }
}

// Extension
extension Reactive where Base: MovieMaker.Filter.CollectionView.Cell {
    
    /// `BindingTarget<Bool>` indicating whether `self` is selected
    var isSelected: BindingTarget<Bool> {
        return self.makeBindingTarget { `self`, value in
            `self`.indicator.isHidden = !value
        }
    }
}
