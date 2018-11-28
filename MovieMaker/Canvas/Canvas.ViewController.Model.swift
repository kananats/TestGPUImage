//
//  Canvas.ViewController.Model.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/19.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift
import KPlugin

// MARK: Main
extension Canvas.ViewController {
    
    /// A `Model` to be binded with `Canvas.ViewController`
    final class Model {
        
        /// Current `UIInterfaceOrientation` (observable)
        let orientation: MutableProperty<UIInterfaceOrientation> = { return MutableProperty(.current) }()
        
        /// Current file URL of selected content (observable)
        let url = MutableProperty<URL?>(nil)
        
        /// Timing offset of current selected content (observable)
        let offset = MutableProperty<TimeInterval>(0)
        
        private let fileURLPipe = Signal<URL, NoError>.pipe()
        
        // TODO: move
        var fileURL: Signal<URL, NoError> { return self.fileURLPipe.output }
        
        /// `Action` for navigating
        lazy var navigateAction: Action<() -> Canvas.ViewController.Navigable, UIViewController, NoError> = {
            return Action { [weak self] value in
                guard let `self` = self, let value = value() as? UIViewController else { return .empty }

                switch value {
                    
                case let value as Video.Record.ViewController:
                    `self`.fileURLPipe <~ value.fileURL
                    
                default:
                    return .empty
                }
                
                return SignalProducer { subscriber, lifetime in
                    subscriber.send(value: value)
                    
                    // Complete when target `Lifetime` has ended
                    lifetime += value.reactive.lifetime.observeEnded {
                         subscriber.sendCompleted()
                    }
                }
            }
        }()
        
        init() {
            self.bind()
        }
    }
}

// MARK: Private
private extension Canvas.ViewController.Model {
    
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        
        
        return disposable
    }
}
