//
//  Filter.CollectionView.Delegate.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import ReactiveSwift

/// `Delegate` for `Filter.CollectionView`
protocol FilterCollectionViewDelegate: class {
    
    /// `BindingTarget<Filter>` for managing adaptive `Filter`
    var filterBindingTarget: BindingTarget<Filter> { get }
}

extension Filter.CollectionView {
    
    /// `Delegate` for `Filter.CollectionView`
    typealias Delegate = FilterCollectionViewDelegate
}
