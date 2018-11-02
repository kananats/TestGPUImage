//
//  MovieMaker.Record.CameraControl.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import GPUImage
import ReactiveCocoa
import ReactiveSwift

extension MovieMaker.Record {
    final class CameraControl: UIView {
        private lazy var recordButton: RecordButton = { return RecordButton() }()

        private lazy var cameraSwitchButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.70)
            button.layer.cornerRadius = 20
            button.clipsToBounds = true
            button.setImage(UIImage(named: "icoCamera")!, for: .normal)
            return button
        }()
        
        private lazy var closeButton: UIButton = {
            let button = UIButton()
            button.setTitle("x", for: .normal)
            button.setTitleColor(.white, for: .normal)
            return button
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)

            self.createLayout()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @discardableResult
        func bind(_ viewModel: ViewModel) -> Disposable {
            let disposable = CompositeDisposable()
            
            disposable += self.recordButton.bind(viewModel)
            
            // Orientation handler
            disposable += self.orientation <~ viewModel.orientation
            
            self.closeButton.reactive.pressed = CocoaAction(viewModel.recordAction)
            
            return disposable
        }
    }
}

private extension MovieMaker.Record.CameraControl {

    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(value) }
    }
    
    func createLayout() {
        guard self.recordButton.superview == nil,
            self.cameraSwitchButton.superview == nil,
            self.closeButton.superview == nil
            else { fatalError() }
        
        self.addSubview(self.recordButton)
        self.addSubview(self.cameraSwitchButton)
        self.addSubview(self.closeButton)

        self.updateLayout(.portrait)
    }
    
    func updateLayout(_ orientation: ImageOrientation) {
        switch orientation {
        case .landscapeLeft, .landscapeRight: `self`.updateLandscapeLayout()
        default: `self`.updatePortraitLayout()
        }
        
        self.recordButton.snp.makeConstraints { make in
            make.width.height.equalTo(81)
        }
    }
    
    func updatePortraitLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
    }
    
    func updateLandscapeLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
    }
}
