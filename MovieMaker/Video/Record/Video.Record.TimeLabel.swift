//
//  Video.Record.TimeLabel.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

extension Video.Record {
    
    /// `UIView` which presents current duration of the recording session
    final class TimeLabel: UIView {
        
        /// `UIImageView` attached
        private let imageView = UIImageView()
        
        /// `UILabel` which presents current duration of the recording session
        private lazy var label: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 24)
            return label
        }()
        
        init(image: UIImage, frame: CGRect = .zero) {
            super.init(frame: frame)
            
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layer.cornerRadius = 21
            
            self.imageView.image = image
            
            self.createLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// Public
extension Video.Record.TimeLabel {
    
    /// `BindingTarget<TimeInterval>` for updating `UILabel`
    var time: BindingTarget<TimeInterval> {
        return self.reactive.makeBindingTarget { `self`, value in `self`.label.attributedText = NSAttributedString(time: value) }
    }
}

// Private
private extension Video.Record.TimeLabel {
    
    /// Layout initialization
    func createLayout() {
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        
        self.updateLayout()
    }

    /// Update constraints
    func updateLayout() {
        self.imageView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        
        self.label.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(34)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

// Extension
extension NSAttributedString {
    
    /// Returns an `NSAttributedString` from the `TimeInterval` given
    fileprivate convenience init(time: TimeInterval) {
        let minute = Int(time / 60)
        let second = Int(time) % 60
        let millisecond = Int(time * 100) % 100
        
        let attributedString = NSAttributedString(minute: minute, second: second, millisecond: millisecond)
        self.init(attributedString: attributedString)
    }
    
    /// Returns an `NSAttributedString` from the minute, second, millisecond given
    private convenience init(minute: Int, second: Int, millisecond: Int) {
        let minuteAndSecond = String(format: "%02ld:%02ld", minute, second)
        let millisecond = String(format: ".%02ld", millisecond)
        
        let attributedMinuteAndSecond = NSMutableAttributedString(string: minuteAndSecond, attributes: [.font: UIFont.systemFont(ofSize: 24)])
        let attributedMilliSecond = NSAttributedString(string: millisecond, attributes: [.font: UIFont.systemFont(ofSize: 16)])
        
        attributedMinuteAndSecond.append(attributedMilliSecond)
        self.init(attributedString: attributedMinuteAndSecond)
    }
}
