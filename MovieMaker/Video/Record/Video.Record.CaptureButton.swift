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

// MARK: Main
extension Video.Record {
    
    /// `UIButton` for starting/ stopping the recording session
    final class CaptureButton: UIButton {
        
        /// Is currently recording
        private var _isRecording = false
        
        /// Foreground `CALayer`
        private lazy var foregroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = CaptureButton.foregroundColor
            return layer
        }()
        
        /// Background `CALayer`
        private lazy var backgroundLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = CaptureButton.backgroundColor
            return layer
        }()
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.layer.addSublayer(self.backgroundLayer)
            self.layer.addSublayer(self.foregroundLayer)
        }()
        
        override init(frame: CGRect = .zero) { super.init(frame: frame) }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
extension Video.Record.CaptureButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = self.makeLayout
        
        self.updateLayout(isRecording: self._isRecording)
    }
}

// MARK: Internal
internal extension Video.Record.CaptureButton {
    
    /// Bind with `Video.Record.ViewController.Model`
    @discardableResult
    func bind(with model: Video.Record.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.isRecording <~ model.isRecording
        
        self.reactive.pressed = CocoaAction(model.countdownOrRecordToggleAction)
        
        return disposable
    }
}

// MARK: Private
private extension Video.Record.CaptureButton {
    
    /// `CGColor` when `self` is enabled
    static let foregroundColor = UIColor(red: 247.0 / 255.0, green: 9.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.9).cgColor

    /// `CGColor` for the background
    static let backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
    
    /// `BindingTarget<Bool>` for managing adaptive recording status
    var isRecording: BindingTarget<Bool> {
        return self.reactive.makeBindingTarget { `self`, value in `self`._isRecording = value }
    }
    
    /// Update layout constraints
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


