//
//  ViewController.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/10/29.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import GPUImage
import SnapKit
import CoreMedia

extension MovieMaker.Record {
    
    /// `UIViewController` for recording
    final class ViewController: UIViewController {
        
        /// `Model` for this `UIViewController`
        private let model: Model! = Model()
        
        /// Interactive `CameraControl` elements
        private let cameraControl = CameraControl()
        
        /// Live preview
        private lazy var renderView: RenderView = {
            let renderView = RenderView()
            renderView.fillMode = .stretch
            renderView.layer.mask = self.mask
            return renderView
        }()
        
        /// Mask used for square `Shape`
        private lazy var mask: CALayer = {
            let mask = CALayer()
            mask.frame = self.view.bounds
            mask.backgroundColor = UIColor.black.cgColor
            return mask
        }()
    }
}

// Inheritance
extension MovieMaker.Record.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createLayout()
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
        
        self.bind(self.model)

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

// Private
private extension MovieMaker.Record.ViewController {
    
    /// Bind with `Model`
    @discardableResult
    func bind(_ model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.cameraControl.bind(model)
        
        disposable += self.orientation <~ model.orientation
        disposable += self.shape <~ model.shape
        
        // Dismiss `UIViewController`
        disposable += model.dismissAction.values.observeValues { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        return disposable
    }
    
    /// `BindingTarget<ImageOrientation>` for managing adaptive `ImageOrientation`
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.renderView.orientation = value }
    }
    
    /// `BindingTarget<Shape>` for managing adaptive `Shape`
    var shape: BindingTarget<Shape> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateShape(value) }
    }
    
    /// Layout initialization
    func createLayout() {
        self.view.addSubview(self.renderView)
        self.view.addSubview(self.cameraControl)

        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.renderView.snp.remakeConstraints { make in make.edges.equalToSuperview() }
        self.cameraControl.snp.remakeConstraints { make in make.edges.equalToSuperview() }
    }

    /// Update mask area corresponding to `Shape`
    func updateShape(_ shape: Shape) {
        let frame = self.view.bounds.applying(shape)
        print(frame)
        let (bounds, position) = frame.makeBoundsAndPosition()

        self.mask.bounds = bounds
        self.mask.position = position
    }
}
