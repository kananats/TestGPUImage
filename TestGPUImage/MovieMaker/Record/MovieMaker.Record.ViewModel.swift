//
//  ViewModel.swift
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

extension MovieMaker.Record {
    
    /// `ViewModel` to be binded with `MovieMaker.Record.ViewController`
    final class ViewModel {
        
        /// Current `Camera`
        private lazy var camera: MutableProperty<Camera> = {
            return MutableProperty(self.frontCamera)
        }()
        
        /// Front `Camera`
        private lazy var frontCamera: Camera! = {
            return try? Camera(sessionPreset: .hd1280x720, location: .frontFacing)
        }()
        
        /// Rear `Camera`
        private lazy var backCamera: Camera! = {
            return try? Camera(sessionPreset: .hd1280x720, location: .backFacing)
        }()
        
        private let noFilter = GammaAdjustment()
        private let smoothToonFilter = SmoothToonFilter()
        
        /// Current applied filter
        private lazy var filter: MutableProperty<ImageProcessingOperation> = {
            return MutableProperty(self.noFilter)
        }()
        
        /// Preview this live output with `RenderView`
        let previewOutput = GammaAdjustment()
        
        private var movieOutput: MovieOutput!
        private var fileURL: URL!
        
        /// Current `Camera` orientation
        lazy var orientation: MutableProperty<ImageOrientation> = {
            let orientation = ImageOrientation.from(deviceOrientation: UIDevice.current.orientation) ?? .portrait
            return MutableProperty(orientation)
        }()
        
        /// Current recording session duration
        let recordDuration = MutableProperty<TimeInterval>(0)
        
        
        /// Is countdown timer enabled
        let isCountdownEnabled = MutableProperty<Bool>(false)

        /// `Action` to toggle recording on/ off. Timer takes priority.
        lazy var toggleRecordAction: Action<Void, Void, NoError> = {
            return Action { [weak self] in
                guard let `self` = self else { return .empty }
                
                let shouldStart = !`self`.isRecordingOrCountingDown.value
                
                return SignalProducer { subscriber, _ in
                    subscriber.sendCompleted()
                    
                    guard shouldStart else { return }

                    let timerDuration = ViewModel.maxTimerDuration
                    if timerDuration > 0, `self`.isCountdownEnabled.value { `self`.countdownAction.apply(timerDuration).start() }
                    else { `self`.recordAction.apply().start() }
                }
            }
        }()
        
        /// `Action` to start countdown timer. Recording will take place right after timer expires.
        private lazy var countdownAction: Action<Int, Int, NoError> = {
            return Action { [weak self] input in
                guard let `self` = self, input > 0 else { return .empty }
                
                return SignalProducer { subscriber, lifetime in
                    lifetime += SignalProducer.timer(from: TimeInterval(input)).startWithValues { value in
                        subscriber.send(value: Int(value))
                        if value <= 0 {
                            `self`.recordAction.apply().start()
                            
                            subscriber.send(value: input)
                            subscriber.sendCompleted()
                        }
                    }
                    
                    lifetime += `self`.toggleRecordAction.completed.signal.observeValues {
                        subscriber.send(value: input)
                        subscriber.sendInterrupted()
                    }
                }
            }
        }()
        
        
        /// `Action` to activate/ deactivate countdown timer
        lazy var countdownToggleAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) { [weak self] in
                guard let `self` = self else { return .empty }
                
                let value = !`self`.isCountdownEnabled.value
                `self`.isCountdownEnabled.swap(value)
                
                return .empty
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
                    
                    lifetime += `self`.toggleRecordAction.completed.signal.observeValues {
                        let fileURL = `self`.stopRecording()
                        
                        subscriber.send(value: fileURL)
                        subscriber.sendCompleted()
                    }
                }
            }
        }()
 
        /// `Action` to switch between front/ rear `Camera`
        lazy var cameraSwitchAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) { [weak self] in
                guard let `self` = self else { return .empty }
                
                var camera = `self`.frontCamera!
                if camera == `self`.camera.value { camera = `self`.backCamera }
                
                `self`.camera.swap(camera)
                
                return .empty
            }
        }()
        
        /// `Action` to toggle filter select view
        lazy var filterSelectToggleAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) {
                return .empty
            }
        }()
        
        /// `Action` to select filter
        private lazy var filterSelectAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecordingOrCountingDown) {
                return .empty
            }
        }()
        
        /// `Action` to dismiss `ViewController`
        lazy var dismissAction: Action<Void, Void, NoError> = { return .single(enabledIf: !self.isRecording) }()
        
        init?() {
            guard self.frontCamera != nil, self.backCamera != nil else { return nil }
            
            self.bind()
        }
    }
}

// Public
extension MovieMaker.Record.ViewModel {
    
    /// Is currently recording
    var isRecording: Property<Bool> { return self.recordAction.isExecuting }
    
    /// Is timer currently counting down
    var isCountingDown: Property<Bool> { return self.countdownAction.isExecuting }
    
    /// Is currently either recording or counting down
    var isRecordingOrCountingDown: Property<Bool> { return self.isRecording || self.isCountingDown }
    
    /// Current countdown timer duration
    var countdownTimerDuration: Property<Int> {
        return Property(initial: MovieMaker.Record.ViewModel.maxTimerDuration, then: self.countdownAction.values)
    }
    /// Maximum countdown timer duration
    static let maxTimerDuration = 3
}

// Private
private extension MovieMaker.Record.ViewModel {
    
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        // Apply filter
        disposable += self.filter.producer.optionalize().combinePrevious(nil).startWithValues { [weak self] previous, current in
            guard let `self` = self else { return }
            
            `self`.camera.value.removeAllTargets()
            previous?.removeAllTargets()
            
            `self`.camera.value.addTarget(current!)
            current! --> `self`.previewOutput
        }
        
        // Switch camera
        disposable += self.camera.producer.optionalize().combinePrevious(nil).startWithValues { [weak self] previous, current in
            guard let `self` = self else { return }
            
            sharedImageProcessingContext.runOperationSynchronously{
                previous?.stopCapture()
                previous?.removeAllTargets()
            }
            
            current!.addTarget(`self`.filter.value)
            current!.startCapture()
        }
        
        return disposable
    }
    
    /// Implementation of start recording
    func startRecording(fileURL: URL) throws {
        self.fileURL = fileURL
        
        try? FileManager.default.removeItem(at: self.fileURL)
        
        self.movieOutput = try MovieOutput(URL: self.fileURL, size: Size(width: 480, height: 640), liveVideo: true)
        self.frontCamera.audioEncodingTarget = self.movieOutput!
        self.previewOutput --> self.movieOutput!
        
        self.movieOutput!.startRecording()
    }
    
    /// Implementation of stop recording
    func stopRecording() -> URL {
        self.movieOutput!.finishRecording {
            self.camera.value.audioEncodingTarget = nil
            self.movieOutput = nil
        }
        
        return self.fileURL!
    }
}
