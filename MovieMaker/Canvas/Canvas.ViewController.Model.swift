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

extension Canvas.ViewController {
    
    /// `Model` to be binded with `Canvas.ViewController`
    final class Model {
        
        /// `Action` for navigating
        lazy var navigateAction: Action<Void, UIViewController, NoError> = {
            return Action { [weak self] in
                guard let `self` = self else { return .empty }
                
                return SignalProducer { subscriber, _ in
                    let vc = Video.Record.ViewController()
                    subscriber.send(value: vc)
                    subscriber.sendCompleted()
                }
            }
        }()
    }
}
