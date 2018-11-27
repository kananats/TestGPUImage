//
//  Canvas.ViewController.Navigable.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/19.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift

/// `UIViewController` that conforms to the `Canvas.ViewController.Navigable` protocol must be navigable from `Canvas.ViewController`
protocol CanvasViewControllerNavigable where Self: UIViewController { }

extension CanvasViewControllerNavigable where Self: Video.Record.ViewController {
    
    /// `URL` of the recorded video file (observable)
    var fileURL: Signal<URL, NoError> {
        return self.model.recordAction.values
    }
}

extension Canvas.ViewController {
    
    /// `UIViewController` that is `Navigable` from `Canvas.ViewController`
    typealias Navigable = CanvasViewControllerNavigable
}
