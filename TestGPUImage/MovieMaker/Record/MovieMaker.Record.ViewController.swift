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
            let viewModel = ViewModel()
            return viewModel
        }()
        
        private lazy var recordButton: RecordButton = {
            let recordButton = RecordButton()
            //recordButton.reactive.pressed = CocoaAction(self.viewModel)
            return recordButton
        }()
        
        private var isRecording = false
        private var movieOutput: MovieOutput?
        
        lazy var renderView: RenderView = {
            let renderView = RenderView()
            renderView.fillMode = .preserveAspectRatioAndFill
            renderView.orientation = .portrait
            return renderView
        }()
        
        let saturationAdjustment = SaturationAdjustment()
    
    }
}

// Public
extension MovieMaker.Record.ViewController {
    
}

// Inheritance
extension MovieMaker.Record.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("kdev viewDidLoad")
        
        self.view.addSubview(self.renderView)
        
        self.renderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.viewModel != nil else {
            print("kdev viewDidAppear failed")
            
            let ac = UIAlertController(title: "Error", message: "Unable to initialize camera", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            self.present(ac, animated: true)
            return
        }
        
        self.viewModel.previewOutput --> self.renderView
    }
}
