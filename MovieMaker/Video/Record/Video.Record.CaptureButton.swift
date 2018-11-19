//
//  Video.Record.CaptureButton.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/10/31.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

extension Video.Record {
    
    /// `UIButton` for starting/ stopping the recording session
    final class CaptureButton: UIButton {
        
        /// Foreground `CALayer`
        private lazy var foregroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = CaptureButton.enableColor.cgColor
            return layer
        }()
        
        /// Background `CALayer`
        private lazy var backgroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = CaptureButton.backgroundColor.cgColor
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
extension Video.Record.CaptureButton {
    
    /// Bind with `Video.Record.ViewController.Model`
    @discardableResult
    func bind(with model: Video.Record.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.isRecording <~ model.isRecording
        
        self.reactive.pressed = CocoaAction(model.countdownOrRecordToggleAction)
        
        return disposable
    }
}

// Inheritance
extension Video.Record.CaptureButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayout(isRecording: false)
    }
}

// Private
extension Video.Record.CaptureButton {
    
    /// `UIColor` when `self` is enabled
    static let enableColor = UIColor(red: 247.0 / 255.0, green: 9.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.9)

    /// `UIColor` for the background
    static let backgroundColor = UIColor.black.withAlphaComponent(0.6)
    
    /// `BindingTarget<Bool>` for managing adaptive recording status
    var isRecording: BindingTarget<Bool> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(isRecording: value) }
    }
    
    /// Layout initialization
    func createLayout() {
        self.layer.addSublayer(self.backgroundLayer)
        self.layer.addSublayer(self.foregroundLayer)
    }
    
    /// Update constraints
    func updateLayout(isRecording: Bool) {
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


