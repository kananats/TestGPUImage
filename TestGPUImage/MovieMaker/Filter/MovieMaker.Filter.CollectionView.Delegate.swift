//
//  MovieMaker.Filter.CollectionView.Delegate.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import ReactiveSwift

/// `Delegate` for `Filter.CollectionView`
protocol MovieMakerFilterCollectionViewDelegate: class {
    
    /// `BindingTarget<Filter>` for managing adaptive `Filter`
    var filterBindingTarget: BindingTarget<MovieMaker.Filter> { get }
}

extension MovieMaker.Filter.CollectionView {
    
    /// `Delegate` for `Filter.CollectionView`
    typealias Delegate = MovieMakerFilterCollectionViewDelegate
}
