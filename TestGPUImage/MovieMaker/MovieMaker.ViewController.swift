//
//  MovieMaker.ViewController.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift

extension MovieMaker {
    
    /// Main `UIViewController` to process movie and voice
    final class ViewController: UIViewController {
        
        /// An `InsertView` for bgm addition/ recording session/ import
        private let insertView = InsertView()
        
        let videoView = MovieMaker.Player.VideoView()
    }
}

// Inheritance
extension MovieMaker.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createLayout()
    }
}

// Private
private extension MovieMaker.ViewController {
    
    /// Layout initialization
    func createLayout() {
        //self.view.addSubview(self.button)
        //self.view.addSubview(self.videoView)
        self.view.addSubview(self.insertView)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        /*
        self.videoView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        */
        
        self.insertView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(110)
            make.centerX.bottom.equalToSuperview()
        }
    }
}
