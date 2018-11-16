//
//  MovieMaker.Player.VideoView.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/14.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift
import ReactiveCocoa
import SnapKit

public extension MovieMaker.Player {
    
    /// `UIView` for playing video file
    final class VideoView: UIView {
        
        private let model = Model()
        
        private lazy var playerLayer: AVPlayerLayer = { return AVPlayerLayer(player: self.model.player) }()
        
        private lazy var playButton: UIButton = {
            let button = UIButton()
            button.setTitle("Play", for: .normal)
            return button
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.createLayout()
            self.prepareToPlay()
            
            self.bind(with: self.model)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
        func prepareToPlay() {
            let url = URL(string: "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.m3u8")!
            let asset = AVAsset(url: url)
            
            let assetKeys = ["playable", "hasProtectedContent"]
            let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
            
            //self.model.
            self.model.playerItem.swap(playerItem)
        }
    }
}

// Public
public extension MovieMaker.Player.VideoView {

}

// Inheritance
public extension MovieMaker.Player.VideoView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayout()
    }
}

// Private
private extension MovieMaker.Player.VideoView {

    /// Bind with `MovieMaker.Player.VideoView.Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        self.playButton.reactive.pressed = CocoaAction(model.playToggleAction)
        
        return disposable
    }
    
    /// Layout initialization
    func createLayout() {
        self.layer.addSublayer(self.playerLayer)
        
        self.addSubview(self.playButton)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.playerLayer.frame = self.bounds
        self.playerLayer.videoGravity = .resizeAspectFill
        
        self.playButton.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }
}
