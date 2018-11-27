//
//  Canvas.Timeline.Header.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/21.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit

// MARK: Main
extension Canvas.Timeline {
    
    /// A `UIView` representing header/ footer content in `Canvas.Timeline`
    final class Header: Canvas.Timeline.Content {
        
        init() {
            super.init(duration: 0)
            
            self.backgroundColor = .black
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
extension Canvas.Timeline.Header {
    
    /// Width of the header content is always half of the bounds
    override var width: Double { return Double(self.bounds.width) / 2 }
    
    override func updateLayout() {
        self.snp.remakeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview()
            if let previous = self.previous { make.left.equalTo(previous.snp.right) }
            else { make.left.equalToSuperview() }
            make.centerY.equalToSuperview()
        }
    }
}
