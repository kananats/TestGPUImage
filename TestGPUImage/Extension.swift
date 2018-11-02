//
//  Extension.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import GPUImage
import ReactiveSwift

public extension PropertyProtocol where Value == Bool {
    /// Create a property that computes a logical NOT in the latest value
    prefix static func ! (a: Self) -> Property<Value> { return a.negate() }
    
    /// Create a property that computes a logical OR between the latest values of two given properties.
    static func || <P: PropertyProtocol> (lhs: Self, rhs: P) -> Property<Value> where P.Value == Value { return lhs.or(rhs) }
    
    /// Create a property that computes a logical AND between the latest values of two given properties.
    static func && <P: PropertyProtocol> (lhs: Self, rhs: P) -> Property<Bool> where P.Value == Value { return lhs.and(rhs) }
}

public extension PropertyProtocol {
    /// Merge the given properties into a single `Property` that will emit all values from all of them. Initial value must be provided.
    static func merge<P: PropertyProtocol>(_ properties: P..., initialValue: Value) -> Property<Value> where P.Value == Value {
        return Property(initial: initialValue, then: Signal.merge(properties.map { property in property.signal }))
    }
    
    /// Merge the given property into a single `Property`. Initial value must be provided.
    func merge<P: PropertyProtocol>(with other: P, initialValue: Value) -> Property<Value> where Value == P.Value  {
        return Property(initial: initialValue, then: Signal.merge(self.signal, other.signal))
    }
}

extension ImageOrientation {
    static func from(deviceOrientation: UIDeviceOrientation) -> ImageOrientation? {
        switch deviceOrientation {
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        case .landscapeLeft:        return .landscapeLeft
        case .landscapeRight:       return .landscapeRight
        default: return nil
        }
    }
    
    static func from(interfaceOrientation: UIInterfaceOrientation) -> ImageOrientation? {
        switch interfaceOrientation {
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        case .landscapeLeft:        return .landscapeLeft
        case .landscapeRight:       return .landscapeRight
        default: return nil
        }
    }
}
