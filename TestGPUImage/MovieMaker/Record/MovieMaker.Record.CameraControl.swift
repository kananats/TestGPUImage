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
            
            self.closeButton.reactive.pressed = CocoaAction(viewModel.closeAction)
            self.cameraSwitchButton.reactive.pressed = CocoaAction(viewModel.cameraSwitchAction)
            
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
        
        self.closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(20) // TODO
            make.top.equalToSuperview().offset(20) // TODO
        }
        
        self.cameraSwitchButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
    }
    
    func updatePortraitLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.left.equalTo(self.snp.right).multipliedBy(74.0 / 375.0)
            make.centerY.equalTo(self.recordButton)
        }
    }
    
    func updateLandscapeLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
        }
        
        self.cameraSwitchButton.snp.remakeConstraints { make in
            make.top.equalTo(self.snp.bottom).multipliedBy(261.0 / 375.0)
            make.centerX.equalTo(self.recordButton)
        }
    }
}
