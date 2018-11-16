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
        
        self.bind(with: self.model)

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
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.cameraControl.bind(with: model)

        disposable += Property.combineLatest(model.orientation, model.shape).producer.startWithValues { [weak self] orientation, shape in
            guard let `self` = self else { return }
            
            `self`.updateLayout(orientation: orientation, shape: shape)
        }
        
        // Dismiss `UIViewController`
        disposable += model.dismissAction.values.observeValues { [weak self] _ in
            guard let `self` = self else { return }

            `self`.dismiss(animated: true)
        }
        
        return disposable
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

    /// Update constraints to fit corresponding `ImageOrientation` and `Shape`
    func updateLayout(orientation: ImageOrientation, shape: Shape) {
        self.renderView.orientation = orientation

        var frame = self.view.bounds
        if frame.width > frame.height { frame = frame.transpose() }
        
        let (bounds, position) = frame.applying(orientation: orientation, shape: shape).makeBoundsAndPosition()
        
        self.mask.bounds = bounds
        self.mask.position = position
    }
}
