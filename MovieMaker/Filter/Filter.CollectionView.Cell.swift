//
//  Filter.CollectionView.Cell.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SnapKit
import GPUImage

// MARK: Main
extension Filter.CollectionView {
    
    /// `Cell` used in `Filter.CollectionView`
    final class Cell: UICollectionViewCell {

        /// `UIView` indicating whether this `Cell` is being selected
        fileprivate let indicator: UIView = {
            let indicator = UIView()
            indicator.backgroundColor = .purple
            return indicator
        }()
        
        /// `UIImageView` previewing `Filter`
        let preview = UIImageView()
        
        /// `UILabel` showing `Filter` name
        let name: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 10)
            label.textColor = .white
            label.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            return label
        }()
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.contentView.addSubview(self.indicator)
            self.contentView.addSubview(self.preview)
            self.contentView.addSubview(self.name)
        }()
        
        override init(frame: CGRect = .zero) { super.init(frame: frame) }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
extension Filter.CollectionView.Cell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = self.makeLayout
        
        self.updateLayout(orientation: .portrait)
    }
}

// MARK: Protocol
extension Filter.CollectionView.Cell: Reusable {
    static let reuseIdentifier = "MovieMakerFilterCollectionViewCell"
}

// MARK: Internal
extension Filter.CollectionView.Cell {
    
    /// `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(orientation: value) }
    }
    
    /// Update `Cell` information using `Filter` information
    func update(filter: Filter) {
        self.name.text = filter.name
        self.preview.image = filter.preview
    }
}

// MARK: Private
private extension Filter.CollectionView.Cell {
    
    /// Update layout constraints to fit corresponding `ImageOrientation`
    func updateLayout(orientation: ImageOrientation) {
        if orientation.isPortrait { self.updatePortraitLayout() }
        else { self.updateLandscapeLayout() }
        
        self.name.snp.remakeConstraints { make in
            make.left.equalTo(self.preview).offset(2)
            make.bottom.equalTo(self.preview).offset(-2)
        }
    }
    
    /// Portrait constraits
    func updatePortraitLayout() {
        self.indicator.snp.remakeConstraints { make in
            make.width.equalTo(3)
            make.height.equalTo(Filter.previewSize.height)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        self.preview.snp.remakeConstraints { make in
            make.size.equalTo(Filter.previewSize)
            make.left.equalTo(self.indicator.snp.right).offset(2)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    /// Landscape constraits
    func updateLandscapeLayout() {
        self.indicator.snp.remakeConstraints { make in
            make.width.equalTo(Filter.previewSize.width)
            make.height.equalTo(3)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.preview.snp.remakeConstraints { make in
            make.size.equalTo(Filter.previewSize)
            make.top.equalTo(self.snp.bottom).offset(2)
            make.centerX.equalTo(self.contentView)
        }
    }
}

// MARK: Extension
extension Reactive where Base: Filter.CollectionView.Cell {
    
    /// `BindingTarget<Bool>` indicating whether `self` is selected
    var isSelected: BindingTarget<Bool> {
        return self.makeBindingTarget { `self`, value in
            `self`.indicator.isHidden = !value
        }
    }
}
