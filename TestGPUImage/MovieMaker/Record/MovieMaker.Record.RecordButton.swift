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
    final class RecordButton: UIButton {
        
        var enableColor = UIColor(red: 247.0 / 255.0, green: 9.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.9) {
            didSet { self.isEnabled = super.isEnabled }
        }
        
        var disableColor = UIColor(red: 247.0 / 255.0, green: 9.0 / 255.0, blue: 128.0 / 255.0, alpha: 0.9) {
            didSet { self.isEnabled = super.isEnabled }
        }
        
        var borderColor: UIColor = .clear {
            didSet {
                self.backgroundLayer.backgroundColor = self.borderColor.cgColor
            }
        }
        
        private lazy var foregroundLayer: CALayer = {
            let foregroundLayer = CALayer()
            foregroundLayer.backgroundColor = self.enableColor.cgColor
            return foregroundLayer
        }()
        
        private lazy var backgroundLayer: CALayer = {
            let backgroundLayer = CALayer()
            backgroundLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
            return backgroundLayer
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
    @discardableResult
    func bind(_ viewModel: MovieMaker.Record.ViewModel) -> Disposable {
        let disposable = CompositeDisposable()
        
        self.isRecording <~ viewModel.isRecording
        
        self.reactive.pressed = CocoaAction(viewModel.toggleRecordAction)
        
        return disposable
    }
}

// Inheritance
extension MovieMaker.Record.RecordButton {
    override var isEnabled: Bool {
        didSet {
            super.isEnabled = self.isEnabled
            
            self.foregroundLayer.backgroundColor = self.isEnabled ? self.enableColor.cgColor : self.disableColor.cgColor;
        }
    }
}

// Private
extension MovieMaker.Record.RecordButton {
    func createLayout() {
        guard self.backgroundLayer.superlayer == nil,
            self.foregroundLayer.superlayer == nil
            else { fatalError() }
        
        self.layer.addSublayer(self.backgroundLayer)
        self.layer.addSublayer(self.foregroundLayer)
    }
    
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
    
    var isRecording: BindingTarget<Bool> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(value) }
    }
}


