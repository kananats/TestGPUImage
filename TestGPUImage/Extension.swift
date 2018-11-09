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
import Result

extension ImageOrientation: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .portrait:             return "portrait"
        case .portraitUpsideDown:   return "portraitUpsideDown"
        case .landscapeLeft:        return "landscapeLeft"
        case .landscapeRight:       return "landscapeRight"
        }
    }
}

public extension Action {
    
    /// Creates an instance of `Action` that would be conditionally enabled, wrapping the original `Action` and will terminate it only if it is being executed. `Bool` value indicating toggle on/ off will be sent as `Output`.
    func makeToggleAction<P: PropertyProtocol>(input: Input, enabledIf isEnabled: P) -> Action<Void, Bool, NoError> where P.Value == Bool {
        var disposable: Disposable?
        
        let action = Action<Void, Bool, NoError>(enabledIf: isEnabled) {
            let isExecuting = self.isExecuting.value
            
            return SignalProducer { subscriber, _ in
                subscriber.send(value: !isExecuting)
                
                if isExecuting {
                    subscriber.sendInterrupted()
                    return
                }

                subscriber.sendCompleted()
                disposable = self.apply(input).start()
            }
        }
        
        self.lifetime += action.events.filter { $0 == .interrupted } .observeValues { _ in
            disposable?.dispose()
        }

        return action
    }
    
    /// Creates an instance of `Action` that wraps the original `Action` and will terminate it only if it is being executed.
    func makeToggleAction(input: Input) -> Action<Void, Bool, NoError> {
        return self.makeToggleAction(input: input, enabledIf: Property(value: true))
    }
}

public extension Action where Input == Void {
    
    /// Creates an instance of `Action` that would be conditionally enabled, wrapping the original `Action` and will terminate it only if it is being executed.
    func makeToggleAction<P: PropertyProtocol>(enabledIf isEnabled: P) -> Action<Void, Bool, NoError> where P.Value == Bool {
        return self.makeToggleAction(input: (), enabledIf: isEnabled)
    }
    
    /// Creates an instance of `Action` that wraps the original `Action` and will terminate it only if it is being executed.
    func makeToggleAction() -> Action<Void, Bool, NoError> {
        return self.makeToggleAction(enabledIf: Property(value: true))
    }
}

public extension TimeInterval {
    
    /// Create an instance of `TimeInterval` from `DispatchTimeInterval`
    init!(_ interval: DispatchTimeInterval) {
        var result: TimeInterval!
        
        switch interval {
        case .seconds(let value):       result = TimeInterval(value)
        case .milliseconds(let value):  result = TimeInterval(value) * 0.001
        case .microseconds(let value):  result = TimeInterval(value) * 0.000001
        case .nanoseconds(let value):   result = TimeInterval(value) * 0.000000001
        default: return nil
        }
        
        self.init(result)
    }
}

public extension SignalProducer {

    /// Zip each element with its corresponding index, which is a consecutive `Int` starting at zero
    func zipWithIndex() -> SignalProducer<(Int, Value), Error> {
        let indexProducer = self.scan(-1) { acc, _ in acc + 1 }
        return indexProducer.zip(with: self)
    }
}

public extension SignalProducer where Value == TimeInterval, Error == NoError {
    
    /// Create a repeating stopwatch of the given interval, sending updates on the given `DateScheduler`. This will never complete naturally.
    static func stopwatch(initial: TimeInterval = 0, interval: DispatchTimeInterval = .seconds(1), on scheduler: DateScheduler = QueueScheduler.main) -> SignalProducer<Value, Error> {
        
        return SignalProducer { subscriber, lifetime in
            subscriber.send(value: initial)
            
            lifetime += SignalProducer<Date, NoError>.timer(interval: interval, on: scheduler).zipWithIndex().map { value in
                let (index, _) = value
                return initial + TimeInterval(index + 1) * TimeInterval(interval)
                }.startWithValues { value in subscriber.send(value: value) }
        }
    }
 
    /// Create a repeating timer that counts either up or down by the given interval, sending updates on the given `DateScheduler`. This will complete automatically as the timer expires.
    static func timer(from: TimeInterval, to: TimeInterval = 0, interval: DispatchTimeInterval = .seconds(1), on scheduler: DateScheduler = QueueScheduler.main) -> SignalProducer<TimeInterval, NoError> {

        return SignalProducer { subscriber, lifetime in
            let increasing = from <= to
            lifetime += SignalProducer.stopwatch(initial: from, interval: interval, on: scheduler).map {
                value in increasing ? value : 2 * from - value
            }.startWithValues { value in
                subscriber.send(value: value)
                if increasing ? value >= to : value <= to { subscriber.sendCompleted() }
            }
        }
    }
}

public extension PropertyProtocol where Value == Bool {
    
    /// Create a `Property` that computes a logical NOT in the latest value
    prefix static func ! (a: Self) -> Property<Value> { return a.negate() }
    
    /// Create a `Property` that computes a logical OR between the latest values of two given properties.
    static func || <P: PropertyProtocol> (lhs: Self, rhs: P) -> Property<Value> where P.Value == Value { return lhs.or(rhs) }
    
    /// Create a `Property` that computes a logical AND between the latest values of two given properties.
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
    
    var isPortrait: Bool { return self == .portrait || self == .portraitUpsideDown }
    var isLandscape: Bool { return !self.isPortrait }
}
