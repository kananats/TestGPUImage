//
//  Filter.CollectionView.Model.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/08.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import GPUImage

extension Filter.CollectionView {
    
    /// `Model` to be binded with `Filter.CollectionView`
    final class Model {
        
        /// Current `ImageOrientation` of `Camera` (observable)
        lazy var orientation: MutableProperty<ImageOrientation> = {
            let orientation = ImageOrientation.from(deviceOrientation: UIDevice.current.orientation) ?? .portrait
            return MutableProperty(orientation)
        }()
        
        /// Current selected `IndexPath` of `CollectionView` (observable)
        let indexPath = MutableProperty<IndexPath>(IndexPath(row: 0, section: 0))
    }
}

// Public
extension Filter.CollectionView.Model {
    
    /// Current applied `Filter` (observable)
    var filter: Property<Filter> {
        return self.indexPath.map { value in Filter.all[value.row] }
    }
}
