//
//  Home.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/14.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit

final class Home: UIViewController {
        
    // Temporary
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.addTarget { [weak self] _ in
            let vc = MovieMaker.Canvas.ViewController()
            self?.present(vc, animated: true)
        }
        
        return button
    }()
}

// Inheritance
extension Home {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createLayout()
    }
}

// Private
extension Home {
    
    /// Layout initialization
    func createLayout() {
        self.view.addSubview(self.button)
        
        self.updateLayout()
    }
    
    func updateLayout() {
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
