//
//  Canvas.ViewController.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift

extension Canvas {
    
    /// Main `UIViewController` for videos and sounds processing 
    public final class ViewController: UIViewController {
        
        /// `Model` for this `UIViewController`
        private let model = Model()
        
        /// A `UIView` for bgm addition/ recording session/ import
        private let insertView = InsertView()
        
        private let videoPlayerView = Video.Player()
        
        /// Bind with `Canvas.ViewController.Model`
        @discardableResult
        func bind(with model: Model) -> Disposable {
            let disposable = CompositeDisposable()
            
            disposable += self.insertView.bind(with: model)
            
            disposable += model.navigateAction.values.observeValues { [weak self] value in
                guard let `self` = self else { return }
                
                `self`.present(value, animated: true)
            }
            
            return disposable
        }
    }
}

// Inheritance
public extension Canvas.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind(with: self.model)
        
        self.createLayout()
    }
}

// Private
private extension Canvas.ViewController {
    
    /// Layout initialization
    func createLayout() {
        //self.view.addSubview(self.button)
        //self.view.addSubview(self.videoView)
        self.view.addSubview(self.insertView)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        /*
        self.videoView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        */
        
        self.insertView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110)
            make.centerX.bottom.equalToSuperview()
        }
    }
}
