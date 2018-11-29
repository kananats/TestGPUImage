//
//  Canvas.Timeline.Video.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/22.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: Main
extension Canvas.Timeline {
    
    /// A `UIView` representing video content in `Canvas.Timeline`
    public final class Video: Canvas.Timeline.Content {
        
        /// An `AVURLAsset` of this content
        let asset: AVURLAsset
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.makeThumbnails()
        }()
        
        init(asset: AVURLAsset) {
            self.asset = asset
            
            super.init(duration: asset.duration.seconds)
            
            self.backgroundColor = .red
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
extension Canvas.Timeline.Video {
    
    override func updateLayout() {
        _ = self.makeLayout
        
        super.updateLayout()
    }
}

// MARK: Public
public extension Canvas.Timeline.Video {
    
    convenience init(url: URL) {
        let asset = AVURLAsset(url: url)
        
        self.init(asset: asset)
    }
    
    /// A `URL` of the video
    var url: URL { return self.asset.url }
}

// MARK: Private
private extension Canvas.Timeline.Video {
    
    /// Renders a series of thumbnails
    func makeThumbnails() {
        
        // Horizontal step
        let step = Canvas.Timeline.widthPerThumbnail
        
        for i in stride(from: 0, to: self.width, by: step)
        {
            // Seconds for taking screenshot
            let seconds = i / Canvas.Timeline.widthPerSecond

            guard let image = self.asset.makeScreenshot(at: seconds) else { return }

            let imageView = UIImageView(image: image)
            self.addSubview(imageView)
            
            imageView.snp.remakeConstraints() { make in
                make.width.equalTo(step)
                make.height.lessThanOrEqualToSuperview()
                make.left.equalToSuperview().offset(i)
                make.centerY.equalToSuperview()
            }
        }
    }
}

