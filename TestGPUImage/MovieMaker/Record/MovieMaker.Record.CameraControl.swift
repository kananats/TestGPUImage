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
        /// Button for recording
        private lazy var recordButton: RecordButton = { return RecordButton() }()

        /// Button for switching between front/ rear camera
        private lazy var cameraSwitchButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.70)
            button.layer.cornerRadius = 20
            button.setImage(UIImage(named: "icoCamera")!, for: .normal)
            return button
        }()
        
        /// Button for activating/ deactivating countdown timer
        private lazy var countdownToggleButton: UIButton = {
            let button = UIButton()
            button.layer.cornerRadius = 20
            button.setImage(UIImage(named: "icoTimer")!, for: .normal)
            return button
        }()
        
        /// Button for dismissing `ViewController`
        private lazy var dismissButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "icoClose")!, for: .normal)
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
            
            self.dismissButton.reactive.pressed = CocoaAction(viewModel.dismissAction)
            self.cameraSwitchButton.reactive.pressed = CocoaAction(viewModel.cameraSwitchAction)
            self.countdownToggleButton.reactive.pressed = CocoaAction(viewModel.countdownToggleAction)
            
            return disposable
        }
    }
}

private extension MovieMaker.Record.CameraControl {
    /// Binding target for handling `ImageOrientation`
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(value) }
    }
    
    /// Layout initialization
    func createLayout() {
        guard self.recordButton.superview == nil,
            self.cameraSwitchButton.superview == nil,
            self.countdownToggleButton.superview == nil,
            self.dismissButton.superview == nil
            else { fatalError() }
        
        self.addSubview(self.recordButton)
        self.addSubview(self.cameraSwitchButton)
        self.addSubview(self.countdownToggleButton)
        self.addSubview(self.dismissButton)

        self.updateLayout(.portrait)
    }
    
    /// Update layout to fit new `orientation`
    func updateLayout(_ orientation: ImageOrientation) {
        switch orientation {
        case .landscapeLeft, .landscapeRight: `self`.updateLandscapeLayout()
        default: `self`.updatePortraitLayout()
        }
        
        self.recordButton.snp.makeConstraints { make in
            make.width.height.equalTo(81)
        }
        
        self.dismissButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(20) // kdev
            make.top.equalToSuperview().offset(20) // kdev
        }
        
        self.cameraSwitchButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        self.countdownToggleButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
    }
    
    /// Portrait only constrait
    func updatePortraitLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.left.equalTo(self.snp.right).multipliedBy(74.0 / 375.0)
            make.centerY.equalTo(self.recordButton)
        }
        
        self.countdownToggleButton.snp.remakeConstraints { make in
            make.left.equalTo(self.snp.right).multipliedBy(261.0 / 375.0)
            make.centerY.equalTo(self.recordButton)
        }
    }
    
    /// Landscape only constrait
    func updateLandscapeLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.top.equalTo(self.snp.bottom).multipliedBy(261.0 / 375.0)
            make.centerX.equalTo(self.recordButton)
        }
        
        self.countdownToggleButton.snp.remakeConstraints { make in
            make.top.equalTo(self.snp.bottom).multipliedBy(74.0 / 375.0)
            make.centerX.equalTo(self.recordButton)
        }
    }
}
