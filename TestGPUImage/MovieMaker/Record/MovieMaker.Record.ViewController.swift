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
        private lazy var viewModel: ViewModel! = {
            guard let viewModel = ViewModel() else { return nil }
            
            self.bind(viewModel)
            return viewModel
        }()
        
        private lazy var cameraControl: CameraControl = { return CameraControl() }()
        
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

        self.makeLayout()
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

        self.viewModel.previewOutput --> self.renderView
    }

    override var shouldAutorotate: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .allButUpsideDown }
    
    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        let orientation = ImageOrientation.from(interfaceOrientation: orientation) ?? .portrait
        
        guard orientation != self.viewModel.orientation.value else { return }
        
        self.viewModel.orientation.swap(orientation)
    }
}

// Private
private extension MovieMaker.Record.ViewController {
    @discardableResult
    func bind(_ viewModel: MovieMaker.Record.ViewModel) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.cameraControl.bind(viewModel)
        
        disposable += self.orientation <~ viewModel.orientation
        
        return disposable
    }
    
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.renderView.orientation = value }
    }
    
    func makeLayout() {
        if self.renderView.superview == nil { self.view.addSubview(self.renderView) }
        if self.cameraControl.superview == nil { self.view.addSubview(self.cameraControl) }
        
        self.renderView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        self.cameraControl.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
}
