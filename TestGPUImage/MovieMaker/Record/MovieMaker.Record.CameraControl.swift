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
    
    /// `UIView` which consists of interactive elements for controlling `MovieMaker.Record.ViewController`
    final class CameraControl: UIView {
        
        /// `UIButton` for recording
        private lazy var recordButton: RecordButton = { return RecordButton() }()

        /// `UIButton` for switching between front/ rear `Camera`
        private lazy var cameraSwitchButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 20
            button.setImage(UIImage(named: "icoCamera")!, for: .normal)
            return button
        }()
        
        /// `TimeLabel` for presenting current duration of the recording session
        private lazy var timeLabel: TimeLabel = { return TimeLabel(image: UIImage(named: "icoMovie")!) }()
        
        /// `UIButton` for activating/ deactivating countdown timer
        private lazy var countdownToggleButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 20
            return button
        }()
        
        /// `UILabel` for presenting countdown timer
        private lazy var countdownLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 180)
            return label
        }()
        
        /// `UIButton` for dismissing `UIViewController`
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
    }
}

// Public
extension MovieMaker.Record.CameraControl {
    
    /// Bind with `MovieMaker.Record.ViewModel`
    @discardableResult
    func bind(_ viewModel: MovieMaker.Record.ViewModel) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.orientation <~ viewModel.orientation
        disposable += self.recordButton.bind(viewModel)
        disposable += self.timeLabel.time <~ viewModel.recordDuration
        disposable += self.countdownToggleButton.reactive.image(for: .normal) <~ viewModel.isCountdownEnabled.map { $0 ? UIImage(named: "icoTimerOff")! : UIImage(named: "icoTimer")! }
        disposable += self.countdownLabel.reactive.isHidden <~ (!viewModel.isCountdownEnabled || viewModel.isRecording)
        disposable += self.countdownLabel.reactive.text <~ viewModel.countdownTimerDuration.map { String($0) }
        
        self.dismissButton.reactive.pressed = CocoaAction(viewModel.dismissAction)
        self.cameraSwitchButton.reactive.pressed = CocoaAction(viewModel.cameraSwitchAction)
        self.countdownToggleButton.reactive.pressed = CocoaAction(viewModel.countdownToggleAction)
        
        return disposable
    }
}

// Private
private extension MovieMaker.Record.CameraControl {
    
    /// `BindingTarget<ImageOrientation>` for adaptive orientation
    var orientation: BindingTarget<ImageOrientation> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.updateLayout(value) }
    }
    
    /// Layout initialization
    func createLayout() {
        guard self.recordButton.superview == nil,
            self.cameraSwitchButton.superview == nil,
            self.timeLabel.superview == nil,
            self.countdownToggleButton.superview == nil,
            self.countdownLabel.superview == nil,
            self.dismissButton.superview == nil
            else { fatalError() }
        
        self.addSubview(self.recordButton)
        self.addSubview(self.cameraSwitchButton)
        self.addSubview(self.timeLabel)
        self.addSubview(self.countdownToggleButton)
        self.addSubview(self.countdownLabel)
        self.addSubview(self.dismissButton)

        self.updateLayout(.portrait)
    }
    
    /// Update constraints to fit new orientation
    func updateLayout(_ orientation: ImageOrientation) {
        switch orientation {
        case .landscapeLeft, .landscapeRight: `self`.updateLandscapeLayout()
        default: `self`.updatePortraitLayout()
        }
        
        self.timeLabel.snp.remakeConstraints { make in
            make.width.equalTo(136)
            make.height.equalTo(44)
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        self.countdownLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalTo(self)
        }
        
        // Temporary
        self.dismissButton.snp.remakeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
        }
    }
    
    /// Portrait constraits
    func updatePortraitLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.width.height.equalTo(81)
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalTo(self.snp.right).multipliedBy(74.0 / 375.0)
            make.centerY.equalTo(self.recordButton)
        }
        
        self.countdownToggleButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalTo(self.snp.right).multipliedBy(261.0 / 375.0)
            make.centerY.equalTo(self.recordButton)
        }
    }
    
    /// Landscape constraits
    func updateLandscapeLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.width.height.equalTo(81)
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.top.equalTo(self.snp.bottom).multipliedBy(261.0 / 375.0)
            make.centerX.equalTo(self.recordButton)
        }
        
        self.countdownToggleButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.top.equalTo(self.snp.bottom).multipliedBy(74.0 / 375.0)
            make.centerX.equalTo(self.recordButton)
        }
    }
}
