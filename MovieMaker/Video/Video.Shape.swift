//
//  Video.Shape.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/12.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import GPUImage

extension Video {

    /// A value describing the intended `Video.Shape` of the recording session
    public enum Shape {
        
        /// Recording as a square `Video.Shape`
        case square
        
        /// Recording as a rectangle `Video.Shape`
        case rectangle
    }
}

// Public
public extension Video.Shape {
    
    /// Return an opposite `Video.Shape`
    func swap() -> Video.Shape {
        if self == .square { return .rectangle }
        return .square
    }
    
    /// Return a `UIImage` used for `Shape` switching button
    var switchButtonImage: UIImage {
        if self == .square { return UIImage(named: "icoSquare")! }
        return UIImage(named: "icoSizeOff")!
    }
}

// Protocol
extension Video.Shape: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .square:       return "Square"
        case .rectangle:    return "Rectangle"
        }
    }
}

extension CGRect {
    
    /// Applies an `ImageOrientation and `Shape` to a `CGRect`
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

extension CGRect {

    /// Converts to `CGRect` bounds and `CGPoint` position
    func makeBoundsAndPosition() -> (bounds: CGRect, point: CGPoint) {
        let bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        let point = CGPoint(x: self.width / 2 - self.origin.x, y: self.height / 2 - self.origin.y)
        return (bounds, point)
    }
    
    /// Creates a `CGRect` by swapping the original width and height
    func transpose() -> CGRect {
        return CGRect.init(origin: self.origin, size: self.size.transpose())
    }
}

public extension CGSize {
    
    /// Creates a `CGSize` by swapping the original width and height
    func transpose() -> CGSize {
        return CGSize(width: self.height, height: self.width)
    }
}
