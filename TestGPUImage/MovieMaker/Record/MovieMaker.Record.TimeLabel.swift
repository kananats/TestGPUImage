//
//  MovieMaker.Record.TimeLabel.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit

extension MovieMaker.Record {
    
    /// `UIView` which shows live duration of the recording session
    final class TimeLabel: UIView {
        
        private lazy var imageView = { return UIImageView() }()
        
        private lazy var label: UILabel = {
            <#statements#>
            return <#value#>
        }()
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layer.cornerRadius = 21
            self.clipsToBounds = true
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
