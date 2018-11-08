//
//  MovieMaker.Filter.CollectionView.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import GPUImage

extension MovieMaker.Filter {
    
    /// `UIView` for selecting filter
    final class CollectionView: UIView {
        
        /// `Delegate` for `MovieMaker.Filter.CollectionView`
        public weak var delegate: Delegate?

        /// `UICollectionView` for selecting filter
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
        private lazy var layout: UICollectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            
            layout.scrollDirection = .horizontal
            
            return layout
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = .clear
            
            self.createLayout()
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
        /*
        let filter = CameraFilterCollectionView.filters[indexPath.row]
        self.delegate?.filterDidSelect(filter)
        */
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        
        cell.indicator.isHidden = false
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell

        cell.indicator.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var size = MovieMaker.Filter.CollectionView.filterSize
        
        //if self.orientation.isPortrait { size.height += 5 }
        //else { size.width += 5 }
        
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

        //cell.indicator.isHidden = !cell.isSelected
        return cell
    }
}

// Private
private extension MovieMaker.Filter.CollectionView {
    
    /// Layout initialization
    func createLayout() {
        guard self.collectionView.superview == nil else { fatalError() }
        
        self.addSubview(self.collectionView)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
