//
//  MovieMaker.Record.CameraControl.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import ReactiveSwift

extension MovieMaker.Record {
    final class CameraControl: UIView {
        private lazy var recordButton: RecordButton = { return RecordButton() }()
        
        private lazy var switchButton: UIButton = {
            let button = UIButton()
            button.setTitleColor(.white, for: .normal)
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
            
            self.addSubview(self.recordButton)
            self.addSubview(self.switchButton)
            self.addSubview(self.closeButton)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @discardableResult
        func bind(_ viewModel: ViewModel) -> Disposable {
            let disposable = CompositeDisposable()
            
            disposable += self.recordButton.bind(viewModel)
            
            self.closeButton.reactive.pressed = CocoaAction(viewModel.recordAction)
            
            return disposable
        }
    }
}

extension MovieMaker.Record.CameraControl {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.recordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        self.switchButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(85)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
}
