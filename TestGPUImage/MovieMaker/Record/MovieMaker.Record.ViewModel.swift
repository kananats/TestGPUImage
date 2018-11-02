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
        private lazy var frontCamera: Camera! = {
            return try? Camera(sessionPreset: .hd1280x720, location: .frontFacing)
        }()
        
        private lazy var backCamera: Camera! = {
            return try? Camera(sessionPreset: .hd1280x720, location: .backFacing)
        }()
        
        private lazy var camera: MutableProperty<Camera> = {
            return MutableProperty(self.frontCamera)
        }()
        
        private let noOperation = GammaAdjustment()
        private let smoothToonFilter = SmoothToonFilter()
        
        private lazy var filter: MutableProperty<ImageProcessingOperation> = {
            return MutableProperty(self.noOperation)
        }()
        
        let previewOutput = GammaAdjustment()
        
        private var movieOutput: MovieOutput!
        private var fileURL: URL!
        let movieOutputUrl = Signal<URL, NSError>.pipe()
        
        lazy var orientation: MutableProperty<ImageOrientation> = {
            let orientation = ImageOrientation.from(deviceOrientation: UIDevice.current.orientation) ?? .portrait
            return MutableProperty(orientation)
        }()
        
        let isRecording = MutableProperty<Bool>(false)
        
        lazy var recordAction: Action<Void, Void, NoError> = { return .single() }()
        lazy var closeAction: Action<Void, Void, NoError> = { return .single(enabledIf: !self.isRecording) }()
        lazy var cameraSwitchAction: Action<Void, Void, NoError> = { return .single(enabledIf: !self.isRecording) }()

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
            
            // Start/ stop recording
            disposable += self.recordAction.values.observeValues { [weak self] _ in
                guard let `self` = self else { return }
                
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
