//
//  MovieMaker.Record.ViewController.Model.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/10/31.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import CoreMedia
import Result
import ReactiveCocoa
import ReactiveSwift
import GPUImage
import KPlugin

extension MovieMaker.Record.ViewController {
    
    /// `Model` to be binded with `Record.ViewController`
    final class Model {
        
        /// Current `Camera` (observable)
        private let camera: MutableProperty<Camera>
        
        /// Preview this live output with `RenderView`
        let previewOutput = GammaAdjustment()
        
        /// Current applied `Filter` (observable)
        let filter = MutableProperty<MovieMaker.Filter>(.off)
        
        /// `MovieOutput` from the recording session
        /// Calling this variable directly may lead to undefined behavior.
        private var movieOutput: MovieOutput!
        
        /// `URL` of the exported movie file.
        /// Calling this variable directly may lead to undefined behavior.
        private var fileURL: URL!
        
        /// Current `ImageOrientation` of `Camera` (observable)
        let orientation: MutableProperty<ImageOrientation> = {
            let orientation = ImageOrientation.from(deviceOrientation: UIDevice.current.orientation) ?? .portrait
            return MutableProperty(orientation)
        }()
        
        /// Current recording session duration (observable)
        let recordDuration = MutableProperty<TimeInterval>(0)
        
        /// Is countdown timer enabled (observable)
        lazy var isCountdownEnabled: Property<Bool> = {
            return Property(initial: false, then: self.countdownToggleAction.values)
        }()

        /// `Action` to start/ stop countdown timer (if any) then start/ stop recording
        lazy var countdownOrRecordToggleAction: Action<Void, Bool, NoError> = {
            return self.countdownOrRecordAction.makeToggleAction(enabledIf: !self.isSelectingFilter)
        }()
        
        /// `Action` to start countdown timer (if any) then start recording
        private lazy var countdownOrRecordAction: Action<Void, Void, NoError> = {
            return Action { [weak self] in
                guard let `self` = self else { return .empty }
                
                return SignalProducer { subscriber, lifetime in
                    var timerDuration = 0
                    if `self`.isCountdownEnabled.value { timerDuration = MovieMaker.Record.ViewController.Model.maxTimerDuration }
                    
                    lifetime += `self`.countdownAction.apply(timerDuration).startWithCompleted {
                        lifetime += `self`.recordAction.apply().start()
                    }
                }
            }
        }()
        
        /// `Action` to start countdown timer
        private lazy var countdownAction: Action<Int, Int, NoError> = {
            return Action { [weak self] input in
                guard let `self` = self, input > 0 else { return .empty }

                return SignalProducer { subscriber, lifetime in
                    lifetime += SignalProducer.timer(from: TimeInterval(input)).startWithValues { value in
                        subscriber.send(value: Int(value))
                        if value <= 0 {
                            subscriber.send(value: input)
                            subscriber.sendCompleted()
                        }
                    }
                    
                    lifetime += `self`.countdownOrRecordToggleAction.values.filter { !$0 } .observeValues { _ in
                        subscriber.send(value: input)
                    }
                }
            }
        }()
        
        /// Actual `Shape` (observable)
        /// This will always return rectangle when in landscape.
        lazy var shape: Property<Shape> = {
            let signal = Signal.merge(self.userSelectedShape.signal, self.orientation.signal.map { [weak self] value -> Shape in
                if value.isPortrait, let shape = self?.userSelectedShape.value { return shape }
                return .rectangle
            }).skipRepeats()
            
            return Property(initial: .rectangle, then: signal)
        }()
        
        /// `Shape` that user selected (observable)
        private lazy var userSelectedShape: Property<Shape> = {
            return Property(initial: .rectangle, then: self.shapeChangeAction.values)
        }()
        
        /// `Action` to switch `Shape` between square and rectangle
        lazy var shapeChangeAction: Action<Void, Shape, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) { [weak self] in
                guard let `self` = self else { return .empty }
                
                let value = `self`.userSelectedShape.value.swap()
                
                return SignalProducer { subscriber, _ in
                    subscriber.send(value: value)
                    subscriber.sendCompleted()
                }
            }
        }()
        
        /// `Action` to enable/ disable countdown timer
        lazy var countdownToggleAction: Action<Void, Bool, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) { [weak self] in
                guard let `self` = self else { return .empty }
                
                let value = !`self`.isCountdownEnabled.value
                
                return SignalProducer { subscriber, _ in
                    subscriber.send(value: value)
                    subscriber.sendCompleted()
                }
            }
        }()
        
        /// Main `Action` for recording
        private lazy var recordAction: Action<Void, URL, NSError> = {
            return Action { [weak self] in
                guard let `self` = self else { return .empty }

                return SignalProducer { subscriber, lifetime in
                    do {
                        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        
                        let fileURL = URL(string: "test.mp4", relativeTo: directory)!
                        
                        try `self`.startRecording(fileURL: fileURL)
                    }
                    catch let error as NSError { subscriber.send(error: error) }
                    
                    lifetime += `self`.recordDuration <~ SignalProducer.stopwatch(interval: .milliseconds(16))
                    
                    lifetime += `self`.countdownOrRecordToggleAction.values.filter { !$0 } .observeValues { _ in
                        let fileURL = `self`.stopRecording()
                        subscriber.send(value: fileURL)
                    }
                }
            }
        }()
 
        /// `Action` to switch between front/ rear `Camera`
        lazy var cameraSwitchAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) { [weak self] in
                guard let `self` = self else { return .empty }
                
                let camera = `self`.camera.value.swap()!
                `self`.camera.swap(camera)
                
                return .empty
            }
        }()
        
        /// `Action` to toggle `Filter` select view
        lazy var filterSelectToggleAction: Action<Void, Bool, NoError> = {
            return filterSelectAction.makeToggleAction(enabledIf: !self.isRecordingOrCountingDown)
        }()
        
        /// `Action` to select `Filter`
        private lazy var filterSelectAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) { [weak self] in
                guard let `self` = self else { return .empty }
                
                return .never
            }
        }()
        
        /// `Action` to dismiss `UIViewController`
        lazy var dismissAction: Action<Void, Void, NoError> = { return .single(enabledIf: !self.isRecording) }()
        
        init?() {
            guard Camera.front != nil, Camera.back != nil else { return nil }
            
            self.camera = MutableProperty(.front)
            
            self.bind()
        }
        
        deinit {
            self.camera.value.stopThenRemoveAllTargets()
        }
    }
}

// Public
extension MovieMaker.Record.ViewController.Model {
    
    /// Maximum countdown timer duration
    static let maxTimerDuration = 3
    
    /// Is currently recording (observable)
    var isRecording: Property<Bool> { return self.recordAction.isExecuting }
    
    /// Is timer currently counting down (observable)
    var isCountingDown: Property<Bool> { return self.countdownAction.isExecuting }
    
    /// Is currently either recording or counting down (observable)
    var isRecordingOrCountingDown: Property<Bool> { return self.countdownOrRecordAction.isExecuting }
    
    /// Is currently selecting `Filter` (observable)
    var isSelectingFilter: Property<Bool> { return self.filterSelectAction.isExecuting }
    
    /// Current countdown timer duration (observable)
    var countdownTimerDuration: Property<Int> {
        return Property(initial: MovieMaker.Record.ViewController.Model.maxTimerDuration, then: self.countdownAction.values)
    }
}

// Protocol
extension MovieMaker.Record.ViewController.Model: MovieMaker.Filter.CollectionView.Delegate {
    
    var filterBindingTarget: BindingTarget<MovieMaker.Filter> { return self.filter.bindingTarget }
}

// Private
private extension MovieMaker.Record.ViewController.Model {

    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        // Apply `Filter`
        disposable += self.filter.map { $0.operation }.producer.optionalize().combinePrevious(nil).startWithValues { [weak self] previous, current in
            guard let `self` = self else { return }
            
            let camera = `self`.camera.value
            camera.removeAllTargets()
            previous?.removeAllTargets()
            
            camera.addTarget(current!)
            current! --> `self`.previewOutput
        }
        
        // Switch `Camera`
        disposable += self.camera.producer.optionalize().combinePrevious(nil).startWithValues { [weak self] previous, current in
            guard let `self` = self else { return }

            previous?.stopThenRemoveAllTargets()
            
            current!.addTarget(`self`.filter.value.operation)
            current!.startCapture()
        }
    
        // Debug purpose
        disposable += self.debug()
        
        return disposable
    }
    
    /// Method for debug purpose
    func debug() -> Disposable {
        let disposable = CompositeDisposable()
        
        //disposable += self.isRecording.producer.startWithValues { print("isRecording \($0)") }
        //disposable += self.isCountingDown.producer.startWithValues { print("isCountingDown \($0)") }
        //disposable += self.recordAction.values.observeValues { print("recordingAction values \($0)") }
        //disposable += self.shape.producer.startWithValues { print("shape \($0)") }
        
        return disposable
    }
    
    /// Implementation of start recording
    func startRecording(fileURL: URL) throws {
        guard self.fileURL == nil else {
            fatalError("Unable to execute `startRecording()` while `stopRecording()` has not been called yet.")
        }
        
        self.fileURL = fileURL
        
        try? FileManager.default.removeItem(at: self.fileURL)
        
        self.movieOutput = try MovieOutput(URL: self.fileURL, size: Size(width: 480, height: 640), liveVideo: true)
        self.camera.value.audioEncodingTarget = self.movieOutput!
        self.previewOutput --> self.movieOutput!
        
        self.movieOutput!.startRecording()
    }
    
    /// Implementation of stop recording
    func stopRecording() -> URL {
        guard let fileURL = self.fileURL else {
            fatalError("Unable to execute `stopRecording()` while `startRecording()` has not been called yet.")
        }
        
        self.movieOutput!.finishRecording {
            self.camera.value.audioEncodingTarget = nil
            self.movieOutput = nil
            
            self.fileURL = nil
        }
        
        return fileURL
    }
}
