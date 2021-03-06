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
        
        /// A `Bool` indicating whether the `AVPlayerItem` would be played automatically when ready
        var playImmediately: Bool
        
        /// A `Bool` indicating whether the `AVPlayerItem` should be played repeatedly
        var loop: Bool
        
        /// Current timing offset of the `AVPlayerItem` (observable)
        /// Returns nil when there is no player item
        let offset = BidirectionalProperty<TimeInterval?>(nil)
        
        /// A `Bool` value that indicates whether the `AVPlayerItem` is ready to play (observable)
        let readyToPlay = MutableProperty<Bool>(false)

        /// A pipe of `Signal<Void, NoError>` sending events when the `AVPlayerItem` has played to its end time (observable)
        private let didPlayToEndTimePipe = Signal<Void, NoError>.pipe()

        /// A `Bool` indicating whether the `AVPlayerItem` is finished playing
        /// If `loop` is `true`, this will not become `true`
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
                    
                    // Observes offset using periodic time observer
                    let interval = CMTime(seconds: 0.01, preferredTimescale: 600)
                    lifetime += `self`.offset <~ `self`.player.reactive.periodicTimeObserver(forInterval: interval).map { $0.seconds }
                    
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
    
    /// A `Bool` indicating whether the `AVPlayerItem` is playing (observable)
    var playing: Property<Bool> { return self.playAction.isExecuting }
    
    /// A `Signal<Void, NoError>` sending events when the `AVPlayerItem` has played to its end time (observable)
    var didPlayToEndTime: Signal<Void, NoError> { return self.didPlayToEndTimePipe.output }
    
    /// A `BindingTarget` for playing the `AVAsset` at `URL`
    var url: BindingTarget<URL?> {
        return self.playerItem.bindingTarget.transform { value in
            guard let value = value else { return nil }
            
            return AVPlayerItem(url: value)
        }
    }
}

// MARK: Private
private extension Video.Player.Model {
 
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        // Play immediately when both `readyToPlay`, and `playImmediately` are `true`
        disposable += self.playToggleAction <~ self.readyToPlay.producer.filter { $0 && self.playImmediately }.map { _ in () }
        
        // Play immediately when both `readyToPlay`, and `loop` are `true`
        disposable += self.playToggleAction <~ self.readyToPlay.producer.filter { $0 && self.loop }.map { _ in () }
        
        // Observes changes to `AVPlayerItem`
        disposable += self.playerItem.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            `self`.finishedPlaying = false
            `self`.readyToPlay.swap(false)
            
            guard let value = value else { return }
            
            `self`.player.replaceCurrentItem(with: value)
            
            disposable += `self`.readyToPlay <~ value.reactive.readyToPlay
            
            disposable += `self`.didPlayToEndTimePipe <~ value.reactive.didPlayToEndTime.ignoreValue()
        }

        // Observes changes to offset
        disposable += self.offset.external.producer.startWithValues { [weak self] value in
            guard let `self` = self, let value = value else { return }

            `self`.seek(to: value)
        }
        
        return disposable
    }
    
    /// Begins playback of `AVPlayerItem`
    func play() {
        guard self.readyToPlay.value else { fatalError("`play()` cannot be called while `readyToPlay` is `false`") }
        
        if self.finishedPlaying {
            self.player.seek(to: .zero)
        }
        
        self.player.play()
    }
    
    /// Pauses playback of `AVPlayerItem`
    func pause() {
        guard self.readyToPlay.value else { fatalError("`pause()` cannot be called while `readyToPlay` is `false`") }
        
        self.player.pause()
    }
    
    /// Sets the current playback time to the specified seconds
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        self.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
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
