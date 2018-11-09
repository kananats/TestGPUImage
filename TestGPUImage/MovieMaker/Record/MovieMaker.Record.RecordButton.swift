//
//  MovieMaker.Record.RecordButton.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/10/31.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import ReactiveSwift

extension MovieMaker.Record {
    
    /// `UIButton` which represents recording button
    final class RecordButton: UIButton {
        
        /// Foreground Layer
        private lazy var foregroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = RecordButton.enableColor.cgColor
            return layer
        }()
        
        /// Background Layer
        private lazy var backgroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = RecordButton.backgroundColor.cgColor
            return layer
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.createLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Public
extension MovieMaker.Record.RecordButton {
    
    /// Bind with `Record.ViewController.Model`
    @discardableResult
    func bind(_ model: MovieMaker.Record.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        self.isRecording <~ model.isRecording
        
        self.reactive.pressed = CocoaAction(model.toggleRecordAction)
        
        return disposable
    }
}

// Private
extension MovieMaker.Record.RecordButton {
    
    /// `UIColor` when `self` is enabled
    static let enableColor = UIColor(red: 247.0 / 255.0, green: 9.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.9)

    /// `UIColor` for the background
    static let backgroundColor = UIColor.black.withAlphaComponent(0.6)
    
    /// `BindingTarget<Bool>` for managing adaptive recording status
    var isRecording: BindingTarget<Bool> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(value) }
    }
    
    /// Layout initialization
    func createLayout() {
        self.layer.addSublayer(self.backgroundLayer)
        self.layer.addSublayer(self.foregroundLayer)
    }
    
    /// Update constraints
    func updateLayout(_ isRecording: Bool) {
        var margin: Double = 8
        var backgroundMargin: Double = 0
        let width = Double(self.frame.width)
        let height = Double(self.frame.height)
        
        var foregroundCornerRadius = width / 2 - margin
        var backgroundCornerRadius = width / 2
        
        if isRecording {
            margin = 16
            backgroundMargin = 8
            backgroundCornerRadius = 0.2 * width
            foregroundCornerRadius = 0.2 * (width - margin * 2)
        }
        
        self.backgroundLayer.frame = CGRect(x: backgroundMargin, y: backgroundMargin, width: width - backgroundMargin * 2, height: height - backgroundMargin * 2)
        self.backgroundLayer.cornerRadius = CGFloat(backgroundCornerRadius)
        
        self.foregroundLayer.frame = CGRect(x: margin, y: margin, width: width - margin * 2, height: height - margin * 2)
        self.foregroundLayer.cornerRadius = CGFloat(foregroundCornerRadius)
    }
}


