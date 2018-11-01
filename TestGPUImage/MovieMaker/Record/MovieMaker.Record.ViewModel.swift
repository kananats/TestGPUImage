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
        private lazy var camera: Camera! = {
            guard let camera = try? Camera(sessionPreset: .high) else { return nil }
            
            if camera.captureSession.canSetSessionPreset(.hd1280x720) {
                camera.captureSession.sessionPreset = .hd1280x720
            }
            
            camera.startCapture()
            return camera
        }()
        
        private let noOperation = GammaAdjustment()
        private let smoothToonFilter = SmoothToonFilter()
        
        private lazy var filter: MutableProperty<ImageProcessingOperation> = {
            return MutableProperty(self.noOperation)
        }()
        
        let previewOutput = GammaAdjustment()
        
        private var movieOutput: MovieOutput!
        let movieOutputUrl = Signal<URL, NSError>.pipe()
        
        let isRecording = MutableProperty<Bool>(false)
        
        lazy var startRecording: Action<Void, Void, NoError> = {
            return Action(enabledIf: !self.isRecording) { _ in .empty }
        }()
        
        lazy var stopRecording: Action<Void, Void, NoError> = {
            return Action(enabledIf: self.isRecording) { _ in .empty }
        }()
        
        init?() {
            guard self.camera != nil else { return nil }
            
            self.bind()
        }
        
        @discardableResult
        func bind() -> Disposable {
            let disposable = CompositeDisposable()
            
            // Apply filter
            disposable += self.filter.producer.optionalize().combinePrevious(nil).startWithValues { [weak self] previous, current in
                guard let `self` = self else { return }
                
                `self`.camera.removeAllTargets()
                previous?.removeAllTargets()
                
                `self`.camera.addTarget(current!)
                current! --> `self`.previewOutput
            }
            
            disposable += self.startRecording.values.observeValues { [weak self] _ in
                guard let `self` = self else { return }
                
                do {
                    try `self`.record(true)
                }
                catch let error as NSError {
                    `self`.movieOutputUrl.input.send(error: error)
                }
            }
            
            disposable += self.stopRecording.values.observeValues { [weak self] _ in
                guard let `self` = self else { return }
                `self`.isRecording.swap(false)
            }
            
            return disposable
        }
        
        func record(_ recording: Bool) throws {
            if recording {
                let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = URL(string: "test.mp4", relativeTo: directory)!
                try FileManager.default.removeItem(at:fileURL)
                
                self.movieOutput = try MovieOutput(URL:fileURL, size: Size(width: 480, height: 640), liveVideo: true)
                self.camera.audioEncodingTarget = self.movieOutput
                self.previewOutput --> self.movieOutput!
                self.movieOutput!.startRecording()
            }
            else {
                self.movieOutput!.finishRecording {
                    self.camera.audioEncodingTarget = nil
                    self.movieOutput = nil
                }
            }
            self.isRecording.swap(recording)
        }
    }
}

// Private
private extension MovieMaker.Record.ViewModel {
    
}
