//
//  Video.Player.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/14.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift
import ReactiveCocoa

// MARK: Main
extension Video {
    
    /// A `UIView` for playing video file
    public final class Player: UIView {
        
        /// A `Model` for this `UIView`
        private let model: Model
        
        /// An `AVPlayerLayer` for playing video
        private lazy var playerLayer: AVPlayerLayer = { AVPlayerLayer(player: self.model.player) }()
        
        /// A `UIButton` for play/ pause `AVPlayerItem`
        private lazy var playButton: UIButton = {
            let button = UIButton()
            button.setTitle("Play", for: .normal)
            return button
        }()
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.layer.addSublayer(self.playerLayer)
            
            self.addSubview(self.playButton)
            
            self.bind(with: self.model)
        }()

        public init(frame: CGRect = .zero, playImmediately: Bool = true, loop: Bool = false) {
            self.model = Model(playImmediately: playImmediately, loop: loop)
            
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
public extension Video.Player {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = self.makeLayout
        
        self.updateLayout()
    }
}

// MARK: Internal
internal extension Video.Player {
    
    /// Bind with `Canvas.ViewController.Model`
    @discardableResult
    func bind(with model: Canvas.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.model.url <~ model.url
        disposable += self.model.offset <~ model.offset
        
        return disposable
    }
}

// MARK: Private
private extension Video.Player {

    /// Bind with `Video.Player.Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        self.playButton.reactive.pressed = CocoaAction(model.playToggleAction)
        
        return disposable
    }
    
    /// Update layout constraints
    func updateLayout() {
        self.playerLayer.frame = self.bounds
        self.playerLayer.videoGravity = .resizeAspectFill

        self.playButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }
}
