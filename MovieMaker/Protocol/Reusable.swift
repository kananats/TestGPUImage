//
//  Reusable.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/08.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit

/// `UIView` that conforms to the `Reusable` protocol must provide its `reuseIdentifier` to be used with `UICollectionView.register(_:forCellWithReuseIdentifier:)` or `UITableView.register(_:forCellWithReuseIdentifier:)`
protocol Reusable where Self: UIView {
    
    /// Reuse identifier to be used with `UICollectionView.register(_:forCellWithReuseIdentifier:)` or `UITableView.register(_:forCellWithReuseIdentifier:)`
    static var reuseIdentifier: String { get }
}
