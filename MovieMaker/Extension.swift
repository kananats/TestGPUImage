//
//  Extension.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation
import Result
import ReactiveSwift
import GPUImage
import KPlugin

public extension UIImage {
    func crop(to rect: CGRect) -> UIImage? {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        
        guard let imageRef = self.cgImage!.cropping(to: rect) else { return nil }
        let image = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

public extension Double {
    
    /// Rounds to decimal places value
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

public extension CGFloat {
    
    /// Rounds to decimal places value
    func rounded(to places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGRect {
    
    /// Converts to `CGRect` bounds and `CGPoint` position
    func makeBoundsAndPosition() -> (bounds: CGRect, point: CGPoint) {
        let bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        let point = CGPoint(x: self.width / 2 - self.origin.x, y: self.height / 2 - self.origin.y)
        return (bounds, point)
    }
}

public extension AVURLAsset {
    
    static let test: AVURLAsset = {
        let path = Bundle.main.path(forResource: "video", ofType:"m4v")!
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url)
        return asset
    }()
}

public extension Reactive where Base: UIScrollView {
    
    /// `BindingTarget<CGSize>` for managing `CGSize` of the content view
    var contentSize: BindingTarget<CGSize> {
        return self.makeBindingTarget { `self`, value in
            `self`.contentSize = value
        }
    }
    
    /// The point at which the origin of the content view is offset from the origin of the scroll view (observable)
    var contentOffset: SignalProducer<CGPoint, NoError> {
        return self.producer(forKeyPath: #keyPath(UIScrollView.contentOffset)).take(duringLifetimeOf: self.base).map { $0 as! CGPoint }
    }
    
    /// The point at which the origin of the content view is offset from the origin of the scroll view, normalized into 0 ... 1 scale (observable)
    var normalizedContentOffset: SignalProducer<CGPoint, NoError> {
        return self.contentOffset.filterMap { [weak base] value in
            
            guard let base = base else { return nil }
            
            var x = (value.x - base.minimumContentOffset.x) / (base.maximumContentOffset.x - base.minimumContentOffset.x)
            var y = (value.y - base.minimumContentOffset.y) / (base.maximumContentOffset.y - base.minimumContentOffset.y)
            
            // Fix NaN
            if x.isNaN || x < 0 { x = 0 }
            if y.isNaN || y < 0 { y = 0 }
            
            // Fix round-off error
            if x > 0.999 { x = 1 }
            if y > 0.999 { y = 1 }
            
            return CGPoint(x: x, y: y)
        }.skipRepeats()
    }
    
    /// The point at which the origin of the content view is offset from the origin of the scroll view, clamped between minimum and maximum possible values (observable)
    var clampedContentOffset: SignalProducer<CGPoint, NoError> {
        return self.contentOffset.filterMap { [weak base] value in
            
            guard let base = base else { return nil }

            let min = base.minimumContentOffset
            let max = base.maximumContentOffset
            
            let x = value.x.clamped(to: min.x ... max.x )
            let y = value.y.clamped(to: min.y ... max.y )
        
            return CGPoint(x: x, y: y)
        }.skipRepeats()
    }
}

public extension UIImage {
    static let icoTimer = UIImage(named: "icoTimer")!
    static let icoTimerOff = UIImage(named: "icoTimerOff")!
}

public extension CGColor {
    static let black = UIColor.black.cgColor
    static let red = UIColor.red.cgColor
}
