//
//  Video.Record.ViewController.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/10/29.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import CoreMedia
import ReactiveSwift
import ReactiveCocoa
import GPUImage
import SnapKit

// MARK: Main
extension Video.Record {
    
    /// `UIViewController` for recording
    final class ViewController: UIViewController {
        
        /// `Model` for this `UIViewController`
        let model: Model! = Model()
        
        /// Interactive `CameraControl` elements
        private let cameraControl = CameraControl()
        
        /// Live preview
        private lazy var renderView: RenderView = {
            let renderView = RenderView()
            renderView.fillMode = .stretch
            renderView.layer.mask = self.mask
            return renderView
        }()
        
        /// Mask used for square `Video.Shape`
        private lazy var mask: CALayer = {
            let mask = CALayer()
            mask.frame = self.view.bounds
            mask.backgroundColor = .black
            return mask
        }()
        
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.view.addSubview(self.renderView)
            self.view.addSubview(self.cameraControl)
            
            guard self.model != nil else { return }
            
            self.bind(with: self.model)
        }()
    }
}

// MARK: Inheritance
extension Video.Record.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.makeLayout
        
        self.updateLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.model != nil else {
            let ac = UIAlertController(title: "Error", message: "Unable to initialize camera", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            self.present(ac, animated: true)
            
            return
        }
        
        self.model.previewOutput --> self.renderView
    }

    override var shouldAutorotate: Bool { return !self.model.isRecordingOrCountingDown.value }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .allButUpsideDown }
    
    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        let orientation = ImageOrientation.from(interfaceOrientation: orientation) ?? .portrait
        
        guard orientation != self.model.orientation.value else { return }
        
        self.model.orientation.swap(orientation)
    }
}

// MARK: Protocol
extension Video.Record.ViewController: Canvas.ViewController.Navigable { }

// MARK: Private
private extension Video.Record.ViewController {
    
    /// Bind with `Video.Record.ViewController.Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.cameraControl.bind(with: model)

        // Update layout constraints to fit corresponding `ImageOrientation` and `Video.Shape`
        disposable += self.orientationAndShape <~ Property.combineLatest(model.orientation, model.shape)
        
        // Dismiss `UIViewController`
        disposable += model.dismissAction.values.observe(on: UIScheduler()).observeValues { [weak self] _ in
            guard let `self` = self else { return }

            `self`.dismiss(animated: true)
        }
        
        return disposable
    }
    
    /// `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation` and `Video.Shape`
    var orientationAndShape: BindingTarget<(ImageOrientation, Video.Shape)> {
        return self.reactive.makeBindingTarget { `self`, value in
            let (orientation, shape) = value
            `self`.updateLayout(orientation: orientation, shape: shape)
        }
    }
    
    /// Update layout constraints
    func updateLayout() {
        self.renderView.snp.remakeConstraints { make in make.edges.equalToSuperview() }
        self.cameraControl.snp.remakeConstraints { make in make.edges.equalToSuperview() }
    }

    /// Update layout constraints to fit corresponding `ImageOrientation` and `Video.Shape`
    func updateLayout(orientation: ImageOrientation, shape: Video.Shape) {
        self.renderView.orientation = orientation

        var frame = self.view.bounds
        if frame.width > frame.height { frame = frame.transpose() }
        
        let (bounds, position) = frame.applying(orientation: orientation, shape: shape).makeBoundsAndPosition()
        
        self.mask.bounds = bounds
        self.mask.position = position
    }
}
