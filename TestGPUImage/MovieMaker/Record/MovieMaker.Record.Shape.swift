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
    
    /// Return a `UIImage` used for `Shape` switching button
    var switchButtonImage: UIImage {
        if self == .square { return UIImage(named: "icoSquare")! }
        return UIImage(named: "icoSizeOff")!
    }
}

// Protocol
extension Shape: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .square:       return "Square"
        case .rectangle:    return "Rectangle"
        }
    }
}

public extension CGRect {
    
    /// Applies a `Shape` to a rectangle.
    func applying(_ shape: Shape) -> CGRect {
        if shape == .rectangle { return self }
        
        let origin = CGPoint(x: 0, y: -30)
        var size = self.size
        
        let min = Swift.min(size.width, size.height)
        size.width = min
        size.height = min
        
        return CGRect(origin: origin, size: size)
    }
    
    /// Converts to `bounds` and `position`
    func makeBoundsAndPosition() -> (bounds: CGRect, point: CGPoint) {
        let bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        let point = CGPoint(x: self.width / 2 - self.origin.x, y: self.height / 2 - self.origin.y)
        return (bounds, point)
    }
}
