//
//  MovieMaker.Record.Shape.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/12.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit

/// A value describing the intended `Shape` of the movie recording session
public enum Shape {
    
    /// Recording as a square `Shape`
    case square
    
    /// Recording as a rectangle `Shape`
    case rectangle
}

// Public
public extension Shape {
    
    /// Return an opposite `Shape`
    func swap() -> Shape {
        if self == .square { return .rectangle }
        return .square
    }
    
    /// Return an image used for `Shape` switching button
    var buttonImage: UIImage {
        if self == .square { return UIImage(named: "icoSquare")! }
        return UIImage(named: "icoSizeOff")!
    }
}

extension Shape: CustomStringConvertible {
    public var description: String {
        switch self {
        case .square:       return "Square"
        case .rectangle:    return "Rectangle"
        }
    }
}
