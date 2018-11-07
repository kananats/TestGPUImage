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
    final class ViewController: UIViewController {
        
        /// `ViewModel` for this `UIViewController`
        private lazy var viewModel: ViewModel! = { return ViewModel() }()
        
        /// Interactive control elements
        private lazy var cameraControl: CameraControl = { return CameraControl() }()
        
        /// Live preview
        private lazy var renderView: RenderView = {
            let renderView = RenderView()
            renderView.fillMode = .stretch
            
            return renderView
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

        guard self.viewModel != nil else {
            let ac = UIAlertController(title: "Error", message: "Unable to initialize camera", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            self.present(ac, animated: true)
            
            return
        }
        
        self.bind(self.viewModel)

        self.viewModel.previewOutput --> self.renderView
    }

    override var shouldAutorotate: Bool { return !self.viewModel.isRecordingOrCountingDown.value }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .allButUpsideDown }
    
    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        let orientation = ImageOrientation.from(interfaceOrientation: orientation) ?? .portrait
        
        guard orientation != self.viewModel.orientation.value else { return }
        
        self.viewModel.orientation.swap(orientation)
    }
}

// Private
private extension MovieMaker.Record.ViewController {
    
    /// Bind with `MovieMaker.Record.ViewModel`
    @discardableResult
    func bind(_ viewModel: MovieMaker.Record.ViewModel) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.cameraControl.bind(viewModel)
        
        disposable += self.orientation <~ viewModel.orientation
        
        // Dismiss `self`
        disposable += viewModel.dismissAction.values.observeValues { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        return disposable
    }
    
    /// `BindingTarget<ImageOrientation>` for adaptive orientation
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.renderView.orientation = value }
    }
    
    /// Layout initialization
    func createLayout() {
        guard self.renderView.superview == nil,
            self.cameraControl.superview == nil
            else { fatalError() }
        
        self.view.addSubview(self.renderView)
        self.view.addSubview(self.cameraControl)
        
        self.renderView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        self.cameraControl.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
}
