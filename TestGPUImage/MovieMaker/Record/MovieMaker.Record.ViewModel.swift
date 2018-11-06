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
    final class ViewModel {
        /// Front-facing camera
        private lazy var frontCamera: Camera! = {
            return try? Camera(sessionPreset: .hd1280x720, location: .frontFacing)
        }()
        
        /// Rear camera
        private lazy var backCamera: Camera! = {
            return try? Camera(sessionPreset: .hd1280x720, location: .backFacing)
        }()
        
        /// Current camera
        private lazy var camera: MutableProperty<Camera> = {
            return MutableProperty(self.frontCamera)
        }()
        
        private let noOperation = GammaAdjustment()
        private let smoothToonFilter = SmoothToonFilter()
        
        /// Current applied filter
        private lazy var filter: MutableProperty<ImageProcessingOperation> = {
            // Defines first filter here
            return MutableProperty(self.noOperation)
        }()
        
        let previewOutput = GammaAdjustment()
        
        private var movieOutput: MovieOutput!
        private var fileURL: URL!
        let movieOutputUrl = Signal<URL, NSError>.pipe()
        
        /// Current camera orientation
        lazy var orientation: MutableProperty<ImageOrientation> = {
            let orientation = ImageOrientation.from(deviceOrientation: UIDevice.current.orientation) ?? .portrait
            return MutableProperty(orientation)
        }()
        
        /// Is currently recording a video
        let isRecording = MutableProperty<Bool>(false)
        
        /// Current recording session length
        let recordingDuration = MutableProperty<Double>(0)
        
        /// Timer countdown duration
        let timerDuration = 0
        
        /// Action to toggle recording on/ off. Timer is taken into account beforehand.
        lazy var recordAction: Action<Void, Void, NSError> = { [weak self] in
            return Action {
                return SignalProducer { subscriber, lifetime in
                    guard let `self` = self else { return }
                    
                    lifetime += `self`.timerAction.apply(`self`.timerDuration).startWithCompleted {
                        defer { subscriber.sendCompleted() }
                        
                        if `self`.isRecording.value {
                            `self`.stopRecording()
                            return
                        }
                        
                        do {
                            try `self`.startRecording()
                        }
                        catch let error as NSError {
                            `self`.movieOutputUrl.input.send(error: error)
                        }
                    }
                }
            }
        }()
        
        /// Action to activate timer
        private lazy var timerAction: Action<Int, Int, NoError> = { [weak self] in
            return Action { input in
                guard let `self` = self, input > 0 else { return .empty }
                
                return SignalProducer { subscriber, lifetime in
                    subscriber.send(value: input)
                    let startTime = Date()
                    
                    lifetime += SignalProducer.timer(interval: .seconds(1), on: QueueScheduler.main).map { value in input - Int(Date().timeIntervalSince(startTime)) }.startWithValues { value in
                        subscriber.send(value: value)
                        if value <= 0 { subscriber.sendCompleted() }
                    }
                }
            }
        }()
        
        lazy var dismissAction: Action<Void, Void, NoError> = { return .single(enabledIf: !self.isRecording) }()
        lazy var cameraSwitchAction: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecording) {
                var camera = self.frontCamera!
                if camera == self.camera.value { camera = self.backCamera }
                
                self.camera.swap(camera)
                return .empty
            }
        }()
        
        init?() {
            guard self.frontCamera != nil, self.backCamera != nil else { return nil }
            
            self.bind()
        }
        
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
            
            disposable += self.cameraSwitchAction.values.observeValues { [weak self] _ in
                guard let `self` = self else { return }

                `self`.switchCamera()
            }

            return disposable
        }
    }
}

// Private
private extension MovieMaker.Record.ViewModel {
    func startRecording() throws {
        guard !self.isRecording.value else { fatalError() }
        
        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        self.fileURL = URL(string: "test.mp4", relativeTo: directory)
        try? FileManager.default.removeItem(at: self.fileURL)
        
        self.movieOutput = try MovieOutput(URL: self.fileURL, size: Size(width: 480, height: 640), liveVideo: true)
        self.frontCamera.audioEncodingTarget = self.movieOutput!
        self.previewOutput --> self.movieOutput!
        self.movieOutput!.startRecording()

        self.isRecording.swap(true)
    }
    
    func stopRecording() {
        guard self.isRecording.value else { fatalError() }
        
        self.isRecording.swap(false)
        
        self.movieOutput!.finishRecording {
            self.frontCamera.audioEncodingTarget = nil
            self.movieOutput = nil
            self.movieOutputUrl.input.send(value: self.fileURL)
            
            self.isRecording.swap(false)
        }
    }
    
    func switchCamera() {
        var camera = self.frontCamera!
        if camera == self.camera.value { camera = self.backCamera }
        
        self.camera.swap(camera)
    }
}
