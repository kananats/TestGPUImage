//
//  Canvas.Timeline.Content.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/21.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift

// MARK: Main
extension Canvas.Timeline {
    
    /// A `UIView` representing each content in `Canvas.Timeline`
    public class Content: UIView {
        
        /// Duration of the content
        let duration: TimeInterval
        
        /// Previous content. Setting this will also adjust layout
        weak var previous: Content?
        
        init(duration: TimeInterval = 0) {
            self.duration = duration
            
            super.init(frame: .infinite)
            
            self.backgroundColor = .random
        }

        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
public extension Canvas.Timeline.Content {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayout()
    }
}

// MARK: Internal
internal extension Canvas.Timeline.Content {

    /// Width of the `Content`
    @objc var width: Double { return self.duration * Double(Canvas.Timeline.widthPerSecond) }
    
    /// Height of the `Content`
    final var height: Double { return Double(self.bounds.height) }
    
    /// Update layout constraints
    @objc func updateLayout() {
        self.snp.remakeConstraints { make in
            make.width.equalTo(self.width)
            make.height.equalToSuperview()
            if let previous = self.previous { make.left.equalTo(previous.snp.right) }
            else { make.left.equalToSuperview() }
            make.centerY.equalToSuperview()
        }
    }
}
