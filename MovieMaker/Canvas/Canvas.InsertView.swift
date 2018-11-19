//
//  Canvas.InsertView.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/16.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

extension Canvas {
    
    /// A `UIView` for bgm insertion/ recording session/ import
    final class InsertView: UIView {
        
        /// A `UIButton` to navigate to `Video.Record.ViewController`
        private let recordButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "btnRecord")!, for: .normal)
            return button
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = .white
            
            self.createLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Public
extension Canvas.InsertView {
    
    /// Bind with `Canvas.ViewController.Model`
    @discardableResult
    func bind(with model: Canvas.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        self.recordButton.reactive.pressed = CocoaAction(model.navigateAction)
        
        return disposable
    }
}

// Private
private extension Canvas.InsertView {
    
    /// Layout initialization
    func createLayout() {
        self.addSubview(self.recordButton)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.centerY.equalToSuperview()
        }
    }
}
