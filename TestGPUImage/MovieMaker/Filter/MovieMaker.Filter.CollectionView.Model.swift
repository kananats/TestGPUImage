//
//  MovieMaker.Filter.CollectionView.Model.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/08.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import GPUImage

extension MovieMaker.Filter.CollectionView {
    
    /// `Model` to be binded with `MovieMaker.Filter.CollectionView`
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
extension MovieMaker.Filter.CollectionView.Model {
    
    /// Current applied `MovieMaker.Filter` (observable)
    var filter: Property<MovieMaker.Filter> {
        return self.indexPath.map { value in MovieMaker.Filter.all[value.row] }
    }
}
