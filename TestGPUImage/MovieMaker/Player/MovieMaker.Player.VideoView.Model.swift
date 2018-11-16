//
//  MovieMaker.Player.VideoView.Model.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/15.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import AVFoundation
import Result
import ReactiveSwift
import KPlugin

internal extension MovieMaker.Player.VideoView {
    
    /// `Model` to be binded with `MovieMaker.Player.VideoView`
    final class Model {
        
        /// `AVPlayer` intended for playing a single media asset at a time
        let player = AVPlayer()
        
        /// Current `AVPlayerItem?` (observable)
        let playerItem = MutableProperty<AVPlayerItem?>(nil)
        
        /// `Bool` indicating whether the `AVPlayerItem` would be played automatically when `readyToPlay` is `true`
        var playImmediately: Bool
        
        /// `Bool` indicating whether the `AVPlayerItem` should be played repeatedly
        var loop: Bool
        
        /// The current `TimeInterval` of the `AVPlayerItem` (observable)
        let currentTime = MutableProperty<TimeInterval>(0)
        
        /// A `Bool` value that indicates whether `AVPlayerItem` is ready to play (observable)
        let readyToPlay = MutableProperty<Bool>(false)

        /// Pipe of `Signal<Void, NoError>` indicating whether `AVPlayerItem` has played to its end time (observable)
        private let didPlayToEndTimePipe = Signal<Void, NoError>.pipe()

        /// `Bool` indicating whether `AVPlayerItem` is finished playing
        /// If `loop` is `true`, this will never become `true`
        private(set) var finishedPlaying = false

        /// `Action` for play/ pause `AVPlayerItem`
        lazy var playToggleAction: Action<Void, Bool, NoError> = {
            return self.playAction.makeToggleAction(enabledIf: self.readyToPlay)
        }()
        
        /// `Action` for play `AVPlayerItem`
        private lazy var playAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: self.readyToPlay) { [weak self] in
                guard let `self` = self else { return .empty }
                
                return SignalProducer { subscriber, lifetime in
                    `self`.play()
                    
                     // When `AVPlayerItem` played to its end time, restarts if `loop`, terminates otherwise
                    lifetime += `self`.didPlayToEndTime.observeValues {
                        `self`.finishedPlaying = true
                        
                        if `self`.loop { `self`.play() }
                        else { subscriber.sendCompleted() }
                    }
                    
                    // Time observer
                    lifetime += `self`.currentTime <~ `self`.playerItem.value!.reactive.currentTime.map { $0.seconds }
                    
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

// Public
extension MovieMaker.Player.VideoView.Model {
    
    /// `Signal<Void, NoError>` indicating whether `AVPlayerItem` has played to its end time (observable)
    var didPlayToEndTime: Signal<Void, NoError> { return self.didPlayToEndTimePipe.output }
}

private extension MovieMaker.Player.VideoView.Model {
    
    /// Begins playback of `AVPlayerItem`
    func play() {
        guard self.readyToPlay.value else { fatalError("`play()` cannot be called while `readyToPlay` is `false`") }
        
        // Reset seek time when `AVPlayerItem` is finished playing
        if self.finishedPlaying { `self`.player.seek(to: .zero) }
        
        self.finishedPlaying = false
        
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
        
        // Play immediately when both `readyToPlay`, `finishedPlaying`, and `loop` are `true`
        disposable += self.playToggleAction <~ self.readyToPlay.producer.filter { $0 && self.loop }.map { _ in () }
        
        // Change to new `AVPlayerItem`
        disposable += self.playerItem.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
                
            guard let value = value else {
                `self`.readyToPlay.swap(false)
                return
            }
            
            `self`.player.replaceCurrentItem(with: value)
            
            let readyToPlay = value.reactive.status.map { $0 == .readyToPlay }
            let isPlaybackLikelyToKeepUp = value.reactive.isPlaybackLikelyToKeepUp
            let isPlaybackBufferFull = value.reactive.isPlaybackBufferFull
            
            `self`.readyToPlay <~ (readyToPlay || isPlaybackLikelyToKeepUp || isPlaybackBufferFull).skipRepeats()
   
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
