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

public extension Signal.Observer where Error == NoError {
    
    /// `Signal.Observer` as `BindingSource`
    @discardableResult
    static func <~ <Source: BindingSource> (provider: Signal.Observer, source: Source) -> Disposable? where Source.Value == Value, Source.Error == NoError {
        return source.producer.startWithValues { value in provider.send(value: value) }
    }
}

public extension Reactive where Base: AVPlayerItem {
    
    /// The `Notification` posted when the `AVPlayerItem` has played to its end time (observable)
    var didPlayToEndTime: Signal<Notification, NoError> {
        return NotificationCenter.default.reactive.notifications(forName: .AVPlayerItemDidPlayToEndTime, object: self.base).take(duringLifetimeOf: self.base)
    }
    
    /// The current `CMTime` of the `AVPlayerItem` (observable)
    var currentTime: SignalProducer<CMTime, NoError> {
        return SignalProducer.stopwatch(interval: .milliseconds(16)).take(duringLifetimeOf: self.base).map { _ in self.base.currentTime() }.skipRepeats()
    }
    
    /// A `Bool` value that indicates whether the `AVPlayerItem` will likely play through without stalling (observable)
    var isPlaybackLikelyToKeepUp: SignalProducer<Bool, NoError> {
        return self.producer(forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp)).take(duringLifetimeOf: self.base).map { $0 as! Bool }
    }
    
    /// A `Bool` value that indicates whether the internal media buffer is full and that further I/O is suspended (observable)
    var isPlaybackBufferFull: SignalProducer<Bool, NoError> {
        return self.producer(forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull)).take(duringLifetimeOf: self.base).map { $0 as! Bool }
    }
    
    /// The `AVPlayerItem.Status` of the `AVPlayerItem` (observable)
    var status: SignalProducer<AVPlayerItem.Status, NoError> {
        return self.producer(forKeyPath: #keyPath(AVPlayerItem.status)).take(duringLifetimeOf: self.base).map { AVPlayerItem.Status(rawValue: $0 as! Int)! }
    }
    
    /// A `Bool` value that indicates whether the `AVPlayerItem` is ready to play (observable)
    var readyToPlay: SignalProducer<Bool, NoError> {
        return (self.status.map { $0 == .readyToPlay } || self.isPlaybackLikelyToKeepUp || self.isPlaybackBufferFull).skipRepeats()
    }
}

public extension Signal where Value == Bool {

    /// Create a `Signal` that computes a logical NOT in the latest value
    prefix static func ! (a: Signal) -> Signal { return a.negate() }
    
    /// Create a `Signal` that computes a logical OR between the latest values of two given signals.
    static func || (lhs: Signal, rhs: Signal) -> Signal { return lhs.or(rhs) }
    
    /// Create a `Signal` that computes a logical AND between the latest values of two given signals.
    static func && (lhs: Signal, rhs: Signal) -> Signal { return lhs.and(rhs) }
}

public extension SignalProducer where Value == Bool {
    
    /// Create a `SignalProducer` that computes a logical NOT in the latest value
    prefix static func ! (a: SignalProducer) -> SignalProducer { return a.negate() }
    
    /// Create a `SignalProducer` that computes a logical OR between the latest values of two given producers.
    static func || (lhs: SignalProducer, rhs: SignalProducer) -> SignalProducer { return lhs.or(rhs) }
    
    /// Create a `SignalProducer` that computes a logical AND between the latest values of two given producers.
    static func && (lhs: SignalProducer, rhs: SignalProducer) -> SignalProducer { return lhs.and(rhs) }
}

public extension Camera {
    
    /// Shorthand for executing `stopCapture()` then `removeAllTargets` on `sharedImageProcessingContext`
    func stopThenRemoveAllTargets() {
        sharedImageProcessingContext.runOperationSynchronously{
            self.stopCapture()
            self.removeAllTargets()
        }
    }
}

extension AVPlayerItem.Status: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .unknown:      return "unknown"
        case .readyToPlay:  return "readyToPlay"
        case .failed:       return "failed"
        }
    }
}
