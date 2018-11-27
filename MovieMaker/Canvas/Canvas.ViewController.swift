//
//  Canvas.ViewController.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import KPlugin

// MARK: Main
extension Canvas {
    
    /// Main `UIViewController` for videos and sounds processing 
    public final class ViewController: UIViewController {
        
        /// A `Model` for this `UIViewController`
        private let model = Model()
        
        /// A `UIView` for preview current videos processing job
        private let playerView = Video.Player()
        
        /// A `UIView` for controlling `Video.Player`
        private lazy var timelineView: Timeline = { return Timeline() }()
        
        /// A `UIView` for bgm addition/ recording session/ import
        private let insertView = InsertView()

        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.view.addSubview(self.playerView)
            self.view.addSubview(self.timelineView)
            self.view.addSubview(self.insertView)
            
            self.bind(with: self.model)
        }()
        
        private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public convenience init() { self.init(nibName: nil, bundle: nil) }
    }
}

// MARK: Inheritance
public extension Canvas.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.makeLayout
        
        self.updateLayout()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .allButUpsideDown }
    
    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard orientation != self.model.orientation.value else { return }
        
        self.model.orientation.swap(orientation)
    }
}

// MARK: Private
private extension Canvas.ViewController {
    
    /// Bind with `Canvas.ViewController.Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.insertView.bind(with: model)
        disposable += self.playerView.bind(with: model)
        disposable += self.timelineView.bind(with: model)
        
        disposable += model.navigateAction.values.observeValues { [weak self] value in
            guard let `self` = self else { return }
            
            `self`.present(value, animated: true)
        }
        
        return disposable
    }

    /// Update layout constraints
    func updateLayout() {
        
        self.playerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.timelineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        /*
        self.insertView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110)
            make.centerX.bottom.equalToSuperview()
        }
        */
    }
}
