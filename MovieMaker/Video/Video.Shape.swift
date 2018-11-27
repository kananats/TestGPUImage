//
//  Video.Shape.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/12.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import GPUImage

// MARK: Main
extension Video {

    /// A value describing the intended `Video.Shape` of the recording session
    public enum Shape {
        
        /// Recording as a square `Video.Shape`
        case square
        
        /// Recording as a rectangle `Video.Shape`
        case rectangle
    }
}

// MARK: Protocol
extension Video.Shape: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .square:       return "Square"
        case .rectangle:    return "Rectangle"
        }
    }
}

// MARK: Public
public extension Video.Shape {
    
    /// Return an opposite `Video.Shape`
    func swap() -> Video.Shape {
        if self == .square { return .rectangle }
        return .square
    }
    
    /// Return a `UIImage` used for `Video.Shape` switching button
    var switchButtonImage: UIImage {
        if self == .square { return UIImage(named: "icoSquare")! }
        return UIImage(named: "icoSizeOff")!
    }
}

// MARK: Extension
extension CGRect {
    
    /// Applies an `ImageOrientation and `Video.Shape` to a `CGRect`
    func applying(orientation: ImageOrientation = .portrait, shape: Video.Shape = .rectangle) -> CGRect {
        var origin = self.origin
        var size = self.size
        
        // Transpose the original size
        if orientation.isLandscape { size = size.transpose() }
        
        // Normalize width and height to the same
        if shape == .square {
            origin = CGPoint(x: 0, y: -30)
            let min = Swift.min(size.width, size.height)
            size.width = min
            size.height = min
        }

        return CGRect(origin: origin, size: size)
    }
}
