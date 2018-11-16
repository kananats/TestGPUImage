//
//  MovieMaker.Canvas.ViewController.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import ReactiveSwift
import UIKit

extension MovieMaker.Canvas {
    
    /// Main `UIViewController` to process movie and voice
    public final class ViewController: UIViewController {
        
        // Temporary
        private lazy var button: UIButton = {
            let button = UIButton()
            button.setTitle("Record", for: .normal)
            button.addTarget { [weak self] _ in
                let vc = MovieMaker.Record.ViewController()
                self?.present(vc, animated: true)
            }
            
            return button
        }()
        
        let videoView = MovieMaker.Player.VideoView()
    }
}

// Inheritance
public extension MovieMaker.Canvas.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createLayout()
        
        //let a = MutableProperty<URL>(URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!)
        //self.videoView.url <~ a
    }
}

// Private
private extension MovieMaker.Canvas.ViewController {
    
    /// Layout initialization
    func createLayout() {
        //self.view.addSubview(self.button)
        self.view.addSubview(self.videoView)
        
        self.updateLayout()
    }
    
    /// Update constraints
    func updateLayout() {
        self.videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
