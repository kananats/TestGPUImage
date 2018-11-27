//
//  Video.Record.CameraControl.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import GPUImage
import KPlugin

// MARK: Main
extension Video.Record {
    
    /// `UIView` which consists of interactive elements for controlling `Video.Record.ViewController`
    final class CameraControl: UIView {
        
        /// Current `ImageOrientation` of `Camera` (observable)
        private let orientation = MutableProperty<ImageOrientation>(.portrait)
        
        /// `UIButton` for start/ stop recording
        private let recordButton = CaptureButton()

        /// `UIButton` for switching between front/ rear `Camera`
        private let cameraSwitchButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 20
            button.setImage(UIImage(named: "icoCamera")!, for: .normal)
            return button
        }()
        
        /// `UIButton` for changing shape mode
        private let shapeChangeButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 20
            //button.setImage(UIImage(named: "icoSizeOff")!, for: .normal)
            return button
        }()
        
        /// `TimeLabel` for presenting current duration of the recording session
        private let timeLabel = TimeLabel(image: UIImage(named: "icoMovie")!)
        
        /// `UIButton` for activating/ deactivating countdown timer
        private let countdownToggleButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 20
            return button
        }()
        
        /// `UILabel` for presenting countdown timer
        private let countdownLabel: UILabel = {
            let label = UILabel()
            label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 180)
            return label
        }()
        
        /// `UIButton` for showing/ hiding `Filter.CollectionView`
        private let filterCollectionViewToggleButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "icoFilter"), for: .normal)
            button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            button.layer.cornerRadius = 20
            return button
        }()
        
        /// `Filter.CollectionView` for selecting `Filter`
        private let filterCollectionView = Filter.CollectionView()
        
        /// `UIButton` for dismissing `UIViewController`
        private let dismissButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "icoClose")!, for: .normal)
            return button
        }()
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.addSubview(self.recordButton)
            self.addSubview(self.cameraSwitchButton)
            self.addSubview(self.shapeChangeButton)
            self.addSubview(self.timeLabel)
            self.addSubview(self.countdownToggleButton)
            self.addSubview(self.countdownLabel)
            self.addSubview(self.filterCollectionViewToggleButton)
            self.addSubview(self.filterCollectionView)
            self.addSubview(self.dismissButton)
            
            self.bind()
        }()
        
        override init(frame: CGRect = .zero) { super.init(frame: frame) }

        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
extension Video.Record.CameraControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = self.makeLayout
    }
}

// MARK: Internal
internal extension Video.Record.CameraControl {
    
    /// Bind with `Video.Record.ViewController.Model`
    @discardableResult
    func bind(with model: Video.Record.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += model.filterBindingTarget <~ self.filterCollectionView.filter
        disposable += [self.orientation.bindingTarget, self.filterCollectionView.orientationBindingTarget] <~ model.orientation
        disposable += self.recordButton.bind(with: model)
        disposable += self.shapeChangeButton.reactive.image(for: .normal) <~ model.shape.map { $0.swap().switchButtonImage }
        disposable += self.timeLabel.time <~ model.recordDuration
        disposable += self.countdownToggleButton.reactive.image(for: .normal) <~ model.isCountdownEnabled.map { $0 ? .icoTimerOff : .icoTimer }
        disposable += self.countdownLabel.reactive.isHidden <~ (!model.isCountdownEnabled || model.isRecording)
        disposable += self.countdownLabel.reactive.text <~ model.countdownTimerDuration.map { String($0) }
        disposable += self.filterCollectionView.reactive.isHidden <~ !model.isSelectingFilter
        
        self.cameraSwitchButton.reactive.pressed = CocoaAction(model.cameraSwitchAction)
        self.shapeChangeButton.reactive.pressed = CocoaAction(model.shapeChangeAction)
        self.countdownToggleButton.reactive.pressed = CocoaAction(model.countdownToggleAction)
        self.filterCollectionViewToggleButton.reactive.pressed = CocoaAction(model.filterSelectToggleAction)
        self.dismissButton.reactive.pressed = CocoaAction(model.dismissAction)
        
        return disposable
    }
}

// MARK: Private
private extension Video.Record.CameraControl {
    
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.orientation.producer.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            `self`.updateLayout(orientation: self.orientation.value)
        }
        
        return disposable
    }
    
    /// Update layout constraints to fit corresponding `ImageOrientation`
    func updateLayout(orientation: ImageOrientation) {
        if orientation.isPortrait { self.updatePortraitLayout() }
        else { self.updateLandscapeLayout() }
        
        self.timeLabel.snp.remakeConstraints { make in
            make.width.equalTo(136)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        self.countdownLabel.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        self.dismissButton.snp.remakeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
        }
    }
    
    /// Update portrait layout constraints
    func updatePortraitLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.width.height.equalTo(81)
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.snp.right).multipliedBy(0.11)
            make.centerY.equalTo(self.recordButton)
        }
        
        self.shapeChangeButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.snp.right).multipliedBy(0.27)
            make.centerY.equalTo(self.recordButton)
        }
        
        self.countdownToggleButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.snp.right).multipliedBy(0.73)
            make.centerY.equalTo(self.recordButton)
        }
        
        self.filterCollectionViewToggleButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.snp.right).multipliedBy(0.89)
            make.centerY.equalTo(self.recordButton)
        }
        
        self.filterCollectionView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(Filter.previewSize.height + 5)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.recordButton.snp.top).offset(-16)
        }
    }
    
    /// Update landscape layout constraints
    func updateLandscapeLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.width.height.equalTo(81)
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.recordButton)
            make.centerY.equalTo(self.snp.bottom).multipliedBy(0.89)
        }
        
        self.shapeChangeButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.recordButton)
            make.centerY.equalTo(self.snp.bottom).multipliedBy(0.73)
        }
        
        self.countdownToggleButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.recordButton)
            make.centerY.equalTo(self.snp.bottom).multipliedBy(0.27)
        }
        
        self.filterCollectionViewToggleButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.recordButton)
            make.centerY.equalTo(self.snp.bottom).multipliedBy(0.11)
        }
        
        self.filterCollectionView.snp.remakeConstraints { make in
            make.width.equalTo(Filter.previewSize.width + 5)
            make.height.equalToSuperview()
            make.right.equalTo(self.recordButton.snp.left).offset(-20)
            make.centerY.equalToSuperview()
        }
    }
}
