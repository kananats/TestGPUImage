//
//  Video.Player.Model.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/15.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import AVFoundation
import Result
import ReactiveSwift
import KPlugin

// MARK: Main
extension Video.Player {
    
    /// A `Model` to be binded with `Video.Player`
    final class Model {
        
        /// An `AVPlayer` intended for playing a single media asset at a time
        let player = AVPlayer()
        
        /// The current `AVPlayerItem?` (observable)
        private let playerItem = MutableProperty<AVPlayerItem?>(nil)
        
        /// A `Bool` indicating whether the `AVPlayerItem` would be played automatically when `readyToPlay` is `true`
        var playImmediately: Bool
        
        /// A `Bool` indicating whether the `AVPlayerItem` should be played repeatedly
        var loop: Bool
        
        /// The current `TimeInterval` of the `AVPlayerItem` (observable)
        let time = MutableProperty<TimeInterval>(0)
        
        /// A `Bool` value that indicates whether the `AVPlayerItem` is ready to play (observable)
        let readyToPlay = MutableProperty<Bool>(false)

        /// A pipe of `Signal<Void, NoError>` indicating whether the `AVPlayerItem` has played to its end time (observable)
        private let didPlayToEndTimePipe = Signal<Void, NoError>.pipe()

        /// A `Bool` indicating whether the `AVPlayerItem` is finished playing
        /// If `loop` is `true`, this will never become `true`
        private var finishedPlaying = false

        /// An `Action` to play/ pause the `AVPlayer`
        lazy var playToggleAction: Action<Void, Bool, NoError> = {
            return self.playAction.makeToggleAction(enabledIf: self.readyToPlay)
        }()
        
        /// An `Action` to play `AVPlayerItem`
        private lazy var playAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: self.readyToPlay) { [weak self] in
                guard let `self` = self else { return .empty }
                
                return SignalProducer { subscriber, lifetime in
                    `self`.play()
                    
                    // When `AVPlayerItem` played to its end time, restarts if `loop`, terminates otherwise
                    lifetime += `self`.didPlayToEndTime.observeValues {
                        `self`.finishedPlaying = true
                        
                        if `self`.loop {
                            `self`.play()
                            return
                        }
                        
                        subscriber.sendCompleted()
                    }
                    
                    // Pause when terminates
                    lifetime.observeEnded { `self`.pause() }
                }
            }
        }()
        
        init(playImmediately: Bool = true, loop: Bool = false) {
            self.playImmediately = playImmediately
            self.loop = loop
            
            self.bind()
        }
    }
}

// MARK: Internal
extension Video.Player.Model {
    
    /// A `Signal<Void, NoError>` indicating whether `AVPlayerItem` has played to its end time (observable)
    var didPlayToEndTime: Signal<Void, NoError> { return self.didPlayToEndTimePipe.output }
    
    /// A `Bool` indicating whether the `AVPlayerItem` is playing (observable)
    var playing: Property<Bool> { return self.playAction.isExecuting }
    
    /// A `BindingTarget` for managing received file
    var fileURL: BindingTarget<URL> {
        return self.playerItem.bindingTarget.transform { AVPlayerItem(url: $0) }
    }
    
    /// Add video at `URL` to `AVPlayerItem`
    func add(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        
        self.playerItem.swap(playerItem)
    }
}

// MARK: Private
private extension Video.Player.Model {
    
    /// Begins playback of `AVPlayerItem`
    func play() {
        guard self.readyToPlay.value else { fatalError("`play()` cannot be called while `readyToPlay` is `false`") }
        
        if `self`.finishedPlaying { `self`.player.seek(to: .zero) }
        
        self.player.play()
    }
    
    /// Pauses playback of `AVPlayerItem`
    func pause() {
        guard self.readyToPlay.value else { fatalError("`pause()` cannot be called while `readyToPlay` is `false`") }
        
        self.player.pause()
    }
    
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        // Play immediately when both `readyToPlay`, and `playImmediately` are `true`
        disposable += self.playToggleAction <~ self.readyToPlay.producer.filter { $0 && self.playImmediately }.map { _ in () }
        
        // Play immediately when both `readyToPlay`, and `loop` are `true`
        disposable += self.playToggleAction <~ self.readyToPlay.producer.filter { $0 && self.loop }.map { _ in () }
        
        // Change to new `AVPlayerItem`
        disposable += self.playerItem.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            `self`.finishedPlaying = false
            `self`.readyToPlay.swap(false)
            
            guard let value = value else { return }
            
            `self`.player.replaceCurrentItem(with: value)
            
            `self`.readyToPlay <~ value.reactive.readyToPlay
            `self`.time <~ value.reactive.currentTime.map { $0.seconds }
   
            `self`.didPlayToEndTimePipe.input <~ value.reactive.didPlayToEndTime.map { _ in () }
        }
        
        // Debug purpose
        disposable += self.debug()
        
        return disposable
    }
    
    /// For debug
    func debug() -> Disposable {
        let disposable = CompositeDisposable()
        
        //disposable += self.isPlaybackLikelyToKeepUp.producer.startWithValues { print("isPlaybackLikelyToKeepUp", $0) }
        //disposable += self.isPlaybackBufferFull.producer.startWithValues { print("isPlaybackBufferFull", $0) }
        //disposable += self.status.producer.startWithValues { print("status", $0) }
        //disposable += self.readyToPlay.producer.startWithValues { print("readyToPlay", $0) }
        //disposable += self.didPlayToEndTime.observeValues { print("didPlayToEndTime") }
        //disposable += self.currentTime.producer.startWithValues { print("readyToPlay", $0) }

        return disposable
    }
}

// MARK: Extension
fileprivate extension AVPlayerItem {
    
    /// Creates an `AVPlayerItem` from `URL`
    convenience init(url: URL) {
        let asset = AVAsset(url: url)
        let assetKeys = ["playable", "hasProtectedContent"]
        
        self.init(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
    }
}
