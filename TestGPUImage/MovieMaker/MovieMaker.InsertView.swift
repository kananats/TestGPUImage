//
//  MovieMaker.InsertView.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/16.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit

extension MovieMaker {
    
    final class InsertView: UIView {
        
        /// A `UIButton` to navigate to `MovieMaker.Record.ViewController`
        private let recordButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "btnRecord")!, for: .normal)
            return button
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = .white
            
            self.createLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Private
private extension MovieMaker.InsertView {
    
    /// Layout initialization
    func createLayout() {
        self.addSubview(self.recordButton)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.recordButton.snp.remakeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.centerY.equalToSuperview()
        }
    }
}
