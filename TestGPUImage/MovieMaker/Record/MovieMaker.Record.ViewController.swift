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
        
        self.view.addSubview(self.renderView)
        self.view.addSubview(self.cameraControl)

        self.renderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.cameraControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        
        self.viewModel.orientation.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            `self`.renderView.orientation = value
        }
    }

    override var shouldAutorotate: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .allButUpsideDown }
    
    override func willRotate(to orientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.viewModel.orientation.swap(ImageOrientation.from(interfaceOrientation: orientation) ?? .portrait)
    }
}

// Private
private extension MovieMaker.Record.ViewController {
    @discardableResult
    func bind(_ viewModel: MovieMaker.Record.ViewModel) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.cameraControl.bind(viewModel)
        
        return disposable
    }
}
