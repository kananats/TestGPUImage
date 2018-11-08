//
//  MovieMaker.Canvas.ViewController.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
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
        
        // Temporary
        func test() {
            
        }
    }
}

// Inheritance
internal extension MovieMaker.Canvas.ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createLayout()
        
        self.test()
    }
}

// Private
private extension MovieMaker.Canvas.ViewController {
    
    /// Layout initialization
    func createLayout() {
        self.view.addSubview(self.button)
        
        self.button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    /// Update constraints
    func updateLayout() {
        
    }
}
